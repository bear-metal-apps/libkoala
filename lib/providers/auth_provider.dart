import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:libkoala/providers/device_info_provider.dart';
import 'package:libkoala/providers/secure_storage_provider.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating }

@riverpod
class AuthStatusNotifier extends _$AuthStatusNotifier {
  @override
  AuthStatus build() => AuthStatus.unauthenticated;
  
  void setStatus(AuthStatus status) {
    state = status;
  }
}

@riverpod
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
    // Use a loopback address for desktop and web
    redirectUri = 'http://localhost:4000';
  }

  final discoveryUrl = Uri.parse(
    'https://login.microsoftonline.com/9bc79ca8-229e-4f3d-990c-300c8407fe5d/v2.0/',
  );
  const clientId = 'c001bbf4-138d-430c-861a-a83535463a53';
  const scopes = ['openid', 'profile', 'email', 'offline_access', 'User.Read'];

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

  Auth({
    required this.ref,
    required this.storage,
    required this.discoveryUrl,
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
    required this.deviceOS,
  });

  Future<TokenResponse> login() async {
    ref.read(authStatusProvider.notifier).setStatus(AuthStatus.authenticating);
    try {
      final issuer = await Issuer.discover(discoveryUrl);
      final client = Client(issuer, clientId);

      final launchMode = switch (deviceOS) {
        DeviceOS.android || DeviceOS.ios => LaunchMode.inAppBrowserView,
        DeviceOS.linux ||
        DeviceOS.macos ||
        DeviceOS.windows ||
        DeviceOS.web => LaunchMode.externalApplication,
      };

      // launch auth in external browser
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

      final json = response.toJson();
      if (json.containsKey('error')) {
        throw Exception(
          'Login failed: ${json['error_description'] ?? json['error']}',
        );
      }

      await _saveTokens(response);
      await _saveCredential(credential);

      ref.read(authStatusProvider.notifier).setStatus(AuthStatus.authenticated);
      return response;
    } catch (e) {
      ref.read(authStatusProvider.notifier).setStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  // Refresh tokens via stored Credential. Returns null if we can't refresh.
  Future<TokenResponse?> refresh() async {
    final rt = await refreshToken;
    if (rt == null) return null;

    final credential = await _loadCredential();
    if (credential == null) return null;

    try {
      // it does it for us, nice
      final response = await credential.getTokenResponse();

      // resave just in case
      await _saveTokens(response);
      await _saveCredential(credential);

      ref.read(authStatusProvider.notifier).setStatus(AuthStatus.authenticated);
      return response;
    } catch (e) {
      // log out because refresh failed (probably revoked/expired tokens)
      await logout();
      rethrow;
    }
  }

  Future<void> _saveTokens(TokenResponse response) async {
    await storage.write(key: 'access_token', value: response.accessToken);

    // better safe than sorry lol
    if (response.refreshToken != null) {
      await storage.write(key: 'refresh_token', value: response.refreshToken);
    }

    await storage.write(
      key: 'id_token',
      value: response.idToken.toCompactSerialization(),
    );
    await storage.write(
      key: 'expires_at',
      value: response.expiresAt?.toUtc().toIso8601String(),
    );
  }

  // Store full Credential JSON so we can rebuild it (Credential has no default ctor)
  Future<void> _saveCredential(Credential credential) async {
    final map = credential.toJson();
    await storage.write(key: 'credential', value: jsonEncode(map));
  }

  Future<Credential?> _loadCredential() async {
    final jsonStr = await storage.read(key: 'credential');
    if (jsonStr == null) return null;

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return Credential.fromJson(map);
  }

  Future<String?> get accessToken async => storage.read(key: 'access_token');

  Future<String?> get refreshToken async => storage.read(key: 'refresh_token');

  Future<String?> get idToken async => storage.read(key: 'id_token');

  Future<DateTime?> get expiresAt async {
    final str = await storage.read(key: 'expires_at');
    if (str == null) return null;
    return DateTime.tryParse(str)?.toUtc();
  }

  Future<void> logout() async {
    await storage.deleteAll();
    ref.read(authStatusProvider.notifier).setStatus(AuthStatus.unauthenticated);
  }
}
