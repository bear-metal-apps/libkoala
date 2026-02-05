import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:libkoala/providers/api_provider.dart'; // Import your dioProvider
import 'package:libkoala/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_info_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UserInfo?> userInfo(Ref ref) async {
  final auth = ref.watch(authProvider);
  final authStatus = ref.watch(authStatusProvider);
  final dio = ref.watch(dioProvider);

  if (authStatus != AuthStatus.authenticated) return null;

  String? accessToken;
  bool isOffline = false;

  try {
    accessToken = await auth.getAccessToken(['User.Read']);
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
    final meResponse = await dio.get(
      'https://graph.microsoft.com/v1.0/me',
      options: Options(
        headers: headers,
        extra: {'isOffline': isOffline},
      ),
    );
    data = meResponse.data as Map<String, dynamic>;
  } catch (e) {
    if (isOffline) return null;
  }

  Uint8List? photoBytes;
  final photoResponse = await dio.get(
    'https://graph.microsoft.com/v1.0/me/photo/\$value',
    options: Options(
      headers: headers,
      responseType: ResponseType.bytes,
      extra: {'isOffline': isOffline},
    ),
  );

  if (photoResponse.statusCode == 200 && photoResponse.data != null) {
    photoBytes = Uint8List.fromList((photoResponse.data as List).cast<int>());
  }

  if (data == null) return null;

  return UserInfo(
    name: data['displayName'] as String?,
    email: (data['mail'] ?? data['userPrincipalName']) as String?,
    photo: photoBytes,
  );
}

class UserInfo {
  final String? name;
  final String? email;
  final Uint8List? photo;

  const UserInfo({this.name, this.email, this.photo});
}
