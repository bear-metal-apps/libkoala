import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_info_provider.g.dart';

const _auth0Domain = 'bearmetal2046.us.auth0.com';

@Riverpod(keepAlive: true)
Future<UserInfo?> userInfo(Ref ref) async {
  final auth = ref.watch(authProvider);
  final authStatus = ref.watch(authStatusProvider);
  final dio = ref.watch(dioProvider);

  if (authStatus != AuthStatus.authenticated) return null;

  String? accessToken;
  bool isOffline = false;

  try {
    accessToken = await auth.getAccessToken(['openid', 'profile', 'email']);
  } on OfflineAuthException {
    isOffline = true;
  } catch (e) {
    rethrow;
  }

  final headers = {
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };

  Map<String, dynamic>? data;

  try {
    final userInfoResponse = await dio.get(
      'https://$_auth0Domain/userinfo',
      options: Options(
        headers: headers,
        extra: {'isOffline': isOffline},
      ),
    );
    data = userInfoResponse.data as Map<String, dynamic>;
  } catch (e) {
    if (isOffline) return null;
    rethrow;
  }

  if (data == null) return null;

  // Fetch profile picture if available
  Uint8List? photoBytes;
  final photoUrl = data['picture'] as String?;

  if (photoUrl != null) {
    try {
      final photoResponse = await dio.get(
        photoUrl,
        options: Options(
          responseType: ResponseType.bytes,
          extra: {'isOffline': isOffline},
        ),
      );

      if (photoResponse.statusCode == 200 && photoResponse.data != null) {
        photoBytes = Uint8List.fromList((photoResponse.data as List).cast<int>());
      }
    } catch (e) {
      // Photo fetch failed, continue without it
    }
  }

  return UserInfo(
    name: data['name'] as String?,
    email: data['email'] as String?,
    photo: photoBytes,
  );
}

class UserInfo {
  final String? name;
  final String? email;
  final Uint8List? photo;

  const UserInfo({this.name, this.email, this.photo});
}