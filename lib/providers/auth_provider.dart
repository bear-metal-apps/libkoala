import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:libkoala/providers/device_info_provider.dart';
import 'package:libkoala/providers/secure_storage_provider.dart';

part 'auth_provider.g.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  authenticating,
}

@Riverpod(keepAlive: true)
class AuthStatusNotifier extends _$AuthStatusNotifier {
  @override
  AuthStatus build() => AuthStatus.unauthenticated;

  void setAuthenticating() => state = AuthStatus.authenticating;
  void setAuthenticated() => state = AuthStatus.authenticated;
  void setUnauthenticated() => state = AuthStatus.unauthenticated;
}

@Riverpod(keepAlive: true)
Auth auth(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  final deviceInfo = ref.watch(deviceInfoProvider);

  final redirectUri = switch (deviceInfo.deviceOS) {
    DeviceOS.ios || DeviceOS.macos =>
    'msauth.org.tahomarobotics.beariscope://auth',
    DeviceOS.android =>
    'msauth://org.tahomarobotics.beariscope/VzSiQcXRmi2kyjzcA%2BmYLEtbGVs%3D',
    DeviceOS.web =>
    'https://scout.bearmet.al/auth.html',
    DeviceOS.windows || DeviceOS.linux =>
    'http://localhost:0/auth',
  };

  return Auth(
    ref: ref,
    storage: storage,
    redirectUri: redirectUri,
  );
}

const _tenantId = '9bc79ca8-229e-4f3d-990c-300c8407fe5d';
const _clientId = 'c001bbf4-138d-430c-861a-a83535463a53';

final _authorizeEndpoint = Uri.parse(
  'https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/authorize',
);

final _tokenEndpoint = Uri.parse(
  'https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/token',
);

class OAuthToken {
  final String accessToken;
  final DateTime expiresAt;
  final String? refreshToken;

  OAuthToken({
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
  });

  bool get isExpired =>
      DateTime.now().toUtc().isAfter(
        expiresAt.subtract(const Duration(minutes: 5)),
      );

  factory OAuthToken.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as int;
    return OAuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt:
      DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
    );
  }
}

class Auth {
  final Ref ref;
  final FlutterSecureStorage storage;
  final String redirectUri;

  OAuthToken? _currentToken;

  Auth({
    required this.ref,
    required this.storage,
    required this.redirectUri,
  });
  
  Future<void> login(List<String> scopes) async {
    ref.read(authStatusProvider.notifier).setAuthenticating();

    try {
      final verifier = _generateCodeVerifier();
      final challenge = _codeChallenge(verifier);

      final authUri = _authorizeEndpoint.replace(queryParameters: {
        'client_id': _clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'scope': scopes.join(' '),
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
      });

      final result = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: Uri.parse(redirectUri).scheme,
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Authorization code missing');
      }

      final token = await _exchangeCode(code, verifier);
      await _persistSession(token);

      _currentToken = token;
      ref.read(authStatusProvider.notifier).setAuthenticated();
    } catch (_) {
      ref.read(authStatusProvider.notifier).setUnauthenticated();
      rethrow;
    }
  }

  Future<String> getAccessToken(List<String> scopes) async {
    if (_currentToken != null && !_currentToken!.isExpired) {
      return _currentToken!.accessToken;
    }

    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      await logout();
      throw Exception('User not authenticated');
    }

    final token = await _refreshToken(refreshToken, scopes);
    _currentToken = token;

    if (token.refreshToken != null) {
      await storage.write(
        key: _refreshTokenKey,
        value: token.refreshToken,
      );
    }

    return token.accessToken;
  }

  Future<void> trySilentLogin() async {
    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      ref.read(authStatusProvider.notifier).setUnauthenticated();
      return;
    }

    try {
      await getAccessToken(const ['openid']);
      ref.read(authStatusProvider.notifier).setAuthenticated();
    } catch (_) {
      await logout();
    }
  }

  Future<void> logout() async {
    _currentToken = null;
    await storage.deleteAll();
    ref.read(authStatusProvider.notifier).setUnauthenticated();
  }
  
  Future<OAuthToken> _exchangeCode(
      String code,
      String verifier,
      ) async {
    final response = await http.post(
      _tokenEndpoint,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': _clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': verifier,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }

    return OAuthToken.fromJson(jsonDecode(response.body));
  }

  Future<OAuthToken> _refreshToken(
      String refreshToken,
      List<String> scopes,
      ) async {
    final response = await http.post(
      _tokenEndpoint,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': _clientId,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'scope': scopes.join(' '),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Token refresh failed: ${response.body}');
    }

    return OAuthToken.fromJson(jsonDecode(response.body));
  }
  
  static const _refreshTokenKey = 'refresh_token';

  Future<void> _persistSession(OAuthToken token) async {
    if (token.refreshToken != null) {
      await storage.write(
        key: _refreshTokenKey,
        value: token.refreshToken,
      );
    }
  }
  
  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(
      64,
          (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  String _codeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
