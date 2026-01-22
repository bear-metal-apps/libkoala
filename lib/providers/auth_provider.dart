import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:libkoala/providers/device_info_provider.dart';
import 'package:libkoala/providers/secure_storage_provider.dart';

part 'auth_provider.g.dart';

const _tenantId = '9bc79ca8-229e-4f3d-990c-300c8407fe5d';
const _clientId = 'c001bbf4-138d-430c-861a-a83535463a53';
const _refreshTokenKey = 'refresh_token';

final _authorizeEndpoint = Uri.parse(
  'https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/authorize',
);

final _tokenEndpoint = Uri.parse(
  'https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/token',
);

enum AuthStatus { authenticated, unauthenticated, authenticating }

@Riverpod(keepAlive: true)
class AuthStatusNotifier extends _$AuthStatusNotifier implements Listenable {
  VoidCallback? _routerListener;

  @override
  AuthStatus build() => AuthStatus.unauthenticated;

  void setStatus(AuthStatus status) {
    if (state != status) {
      state = status;
      notify();
    }
  }

  void notify() => _routerListener?.call();

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) {
    if (_routerListener == listener) _routerListener = null;
  }
}

@Riverpod(keepAlive: true)
Auth auth(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  final deviceInfo = ref.watch(deviceInfoProvider);

  final redirectUri = switch (deviceInfo.deviceOS) {
    DeviceOS.ios ||
    DeviceOS.macos => 'msauth.org.tahomarobotics.beariscope://auth',
    DeviceOS.android =>
      'msauth://org.tahomarobotics.beariscope/VzSiQcXRmi2kyjzcA%2BmYLEtbGVs%3D',
    DeviceOS.web => 'https://scout.bearmet.al/auth.html',
    DeviceOS.windows || DeviceOS.linux => 'http://localhost:4000/auth',
  };

  return Auth(ref: ref, storage: storage, redirectUri: redirectUri);
}

class Auth {
  final Ref ref;
  final FlutterSecureStorage storage;
  final String redirectUri;

  // Cache tokens by their scope string so we don't mix Graph tokens with API tokens
  final Map<String, OAuthToken> _tokenCache = {};

  Auth({required this.ref, required this.storage, required this.redirectUri});

  /// Starts the interactive login flow.
  Future<void> login(List<String> scopes) async {
    _setStatus(AuthStatus.authenticating);

    try {
      // 1. Prepare PKCE
      final verifier = _generateCodeVerifier();
      final challenge = _codeChallenge(verifier);

      // 2. Ensure we get a Refresh Token by asking for offline_access
      final requestScopes = {
        ...scopes,
        'offline_access',
        'openid',
        'profile',
      }.join(' ');

      // 3. Build Auth URL
      final authUrl = _authorizeEndpoint.replace(
        queryParameters: {
          'client_id': _clientId,
          'response_type': 'code',
          'redirect_uri': redirectUri,
          'scope': requestScopes,
          'code_challenge': challenge,
          'code_challenge_method': 'S256',
          // Optional: Force account selection if needed
          // 'prompt': 'select_account',
        },
      );

      // 4. Trigger Web Auth
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: Uri.parse(redirectUri).scheme,
        options: const FlutterWebAuth2Options(useWebview: false),
      );

      // 5. Extract Code
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No authorization code received');

      // 6. Exchange Code for Token
      final token = await _exchangeCode(code, verifier);

      // 7. Save Session
      await _persistRefreshToken(token.refreshToken);

      // Cache this initial token for the scopes we requested
      _tokenCache[scopes.join(' ')] = token;

      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      debugPrint('Login Error: $e');
      _setStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  /// Returns a valid Access Token for the specific scopes requested.
  /// If the cached token is expired or for a different scope, it refreshes automatically.
  Future<String> getAccessToken(List<String> scopes) async {
    final scopeKey = scopes.join(' ');

    // 1. Check Memory Cache
    final cached = _tokenCache[scopeKey];
    if (cached != null && !cached.isExpired) {
      return cached.accessToken;
    }

    // 2. Retrieve Persisted Refresh Token
    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      await logout();
      throw Exception('Session expired (No refresh token)');
    }

    // 3. Fetch New Access Token using Refresh Token
    try {
      final newToken = await _fetchNewToken(refreshToken, scopes);

      // Update Refresh Token if the server rotated it
      if (newToken.refreshToken != null) {
        await _persistRefreshToken(newToken.refreshToken);
      }

      // Update Cache
      _tokenCache[scopeKey] = newToken;

      return newToken.accessToken;
    } catch (e) {
      // If refresh fails (revoked, expired), log out
      await logout();
      throw Exception('Failed to refresh token: $e');
    }
  }

  /// Checks if a valid session exists silently on app start.
  Future<void> trySilentLogin() async {
    _setStatus(AuthStatus.authenticating);

    final refreshToken = await storage.read(key: _refreshTokenKey);

    if (refreshToken != null) {
      try {
        // Just verify we can get a basic token (e.g., for Graph/Profile)
        await getAccessToken(['User.Read']);
        _setStatus(AuthStatus.authenticated);
      } catch (_) {
        // Refresh token invalid
        await logout();
      }
    } else {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> logout() async {
    _tokenCache.clear();
    await storage.deleteAll();
    _setStatus(AuthStatus.unauthenticated);
  }

  void _setStatus(AuthStatus status) {
    ref.read(authStatusProvider.notifier).setStatus(status);
  }

  Future<void> _persistRefreshToken(String? token) async {
    if (token != null) {
      await storage.write(key: _refreshTokenKey, value: token);
    }
  }

  Future<OAuthToken> _exchangeCode(String code, String verifier) async {
    return _postRequest({
      'client_id': _clientId,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'code_verifier': verifier,
    });
  }

  Future<OAuthToken> _fetchNewToken(
    String refreshToken,
    List<String> scopes,
  ) async {
    return _postRequest({
      'client_id': _clientId,
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'scope': scopes.join(' '),
    });
  }

  Future<OAuthToken> _postRequest(Map<String, String> body) async {
    final response = await http.post(
      _tokenEndpoint,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(
        'Auth Error: ${error['error_description'] ?? response.body}',
      );
    }

    return OAuthToken.fromJson(jsonDecode(response.body));
  }

  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(64, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String _codeChallenge(String verifier) {
    return base64UrlEncode(
      sha256.convert(utf8.encode(verifier)).bytes,
    ).replaceAll('=', '');
  }
}

class OAuthToken {
  final String accessToken;
  final DateTime expiresAt;
  final String? refreshToken;

  OAuthToken({
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(
    expiresAt.subtract(const Duration(minutes: 2)), // Buffer time
  );

  factory OAuthToken.fromJson(Map<String, dynamic> json) {
    return OAuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: DateTime.now().toUtc().add(
        Duration(seconds: json['expires_in'] as int),
      ),
    );
  }
}
