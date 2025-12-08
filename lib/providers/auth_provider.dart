import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http; // Required for manual refresh

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:libkoala/providers/device_info_provider.dart';
import 'package:libkoala/providers/secure_storage_provider.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating }

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

  final String redirectUri;
  if (deviceInfo.deviceOS == DeviceOS.ios ||
      deviceInfo.deviceOS == DeviceOS.macos) {
    redirectUri = 'msauth.org.tahomarobotics.beariscope://auth';
  } else if (deviceInfo.deviceOS == DeviceOS.android) {
    redirectUri =
        'msauth://org.tahomarobotics.beariscope/VzSiQcXRmi2kyjzcA%2BmYLEtbGVs%3D';
  } else {
    redirectUri = 'http://localhost:4000';
  }

  final discoveryUrl = Uri.parse(
    'https://login.microsoftonline.com/9bc79ca8-229e-4f3d-990c-300c8407fe5d/v2.0/',
  );
  const clientId = 'c001bbf4-138d-430c-861a-a83535463a53';

  // the scopes we want consent for, not what we're actively getting
  const scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
    'User.Read',
    'https://vault.azure.net/user_impersonation',
  ];

  return Auth(
    ref: ref,
    storage: storage,
    discoveryUrl: discoveryUrl,
    clientId: clientId,
    redirectUri: redirectUri,
    scopes: scopes,
    deviceOS: deviceInfo.deviceOS,
  );
}

class Auth {
  final Ref ref;
  final FlutterSecureStorage storage;
  final Uri discoveryUrl;
  final String clientId;
  final String redirectUri;
  final List<String> scopes;
  final DeviceOS deviceOS;

  final Map<String, TokenResponse> _tokenCache = {};

  Auth({
    required this.ref,
    required this.storage,
    required this.discoveryUrl,
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
    required this.deviceOS,
  });

  Future<String?> getAccessToken(List<String> targetScopes) async {
    final key = _scopesToKey(targetScopes);

    final cached = _tokenCache[key];
    if (cached != null && !_isExpired(cached)) {
      return cached.accessToken;
    }

    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      await logout();
      throw Exception('User not logged in');
    }

    try {
      final client = await _getClient();
      final newResponse = await _manualRefresh(
        client,
        refreshToken,
        targetScopes,
      );

      _cacheToken(newResponse, targetScopes);

      if (newResponse.refreshToken != null) {
        await _saveSession(newResponse);
      }

      return newResponse.accessToken;
    } catch (e) {
      await logout();
      throw Exception('Failed to refresh token: $e');
    }
  }

  Future<TokenResponse> login() async {
    ref.read(authStatusProvider.notifier).setAuthenticating();
    try {
      final client = await _getClient();

      final launchMode = switch (deviceOS) {
        DeviceOS.android || DeviceOS.ios => LaunchMode.inAppBrowserView,
        _ => LaunchMode.externalApplication,
      };

      Future<void> urlLauncher(String url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: launchMode);
        } else {
          throw Exception('Could not launch $url');
        }
      }

      final authenticator = redirectUri.startsWith('http')
          ? Authenticator(
              client,
              scopes: scopes,
              port: Uri.parse(redirectUri).port,
              urlLancher: urlLauncher,
            )
          : Authenticator(client, scopes: scopes, urlLancher: urlLauncher);

      final credential = await authenticator.authorize();
      final response = await credential.getTokenResponse();

      await _saveSession(response);

      // don't cache the initial access token in _tokenCache because we don't know which aud it belongs to

      ref.read(authStatusProvider.notifier).setAuthenticated();
      return response;
    } catch (e) {
      ref.read(authStatusProvider.notifier).setUnauthenticated();
      rethrow;
    }
  }

  Future<void> logout() async {
    _tokenCache.clear();
    await storage.deleteAll();
    ref.read(authStatusProvider.notifier).setUnauthenticated();
  }

  Future<Client> _getClient() async {
    final issuer = await Issuer.discover(discoveryUrl);
    return Client(issuer, clientId);
  }

  Future<TokenResponse> _manualRefresh(
    Client client,
    String refreshToken,
    List<String> targetScopes,
  ) async {
    final tokenEndpoint = client.issuer.metadata.tokenEndpoint;

    final response = await http.post(
      tokenEndpoint!,
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': clientId,
        'scope': targetScopes.join(' '),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Refresh failed: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return TokenResponse.fromJson(json);
  }

  String _scopesToKey(List<String> s) {
    final sorted = List<String>.from(s)..sort();
    return sorted.join(' ');
  }

  void _cacheToken(TokenResponse response, List<String> targetScopes) {
    final key = _scopesToKey(targetScopes);
    _tokenCache[key] = response;
  }

  bool _isExpired(TokenResponse response) {
    final expiresAt = response.expiresAt;
    if (expiresAt == null) return true;
    return DateTime.now().toUtc().isAfter(
      expiresAt.subtract(const Duration(minutes: 5)),
    );
  }

  Future<void> _saveSession(TokenResponse response) async {
    if (response.refreshToken != null) {
      await storage.write(key: 'refresh_token', value: response.refreshToken);
    }
    await storage.write(
      key: 'id_token',
      value: response.idToken.toCompactSerialization(),
    );
  }

  Future<void> trySilentLogin() async {
    final refreshToken = await storage.read(key: 'refresh_token');

    if (refreshToken != null) {
      // if we have a refresh token, it's safe to assume the user is logged in
      ref.read(authStatusProvider.notifier).setAuthenticated();
    } else {
      // no token found, user must log in
      ref.read(authStatusProvider.notifier).setUnauthenticated();
    }
  }
}
