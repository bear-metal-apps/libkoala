import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:libkoala/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_info_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UserInfo?> userInfo(Ref ref) async {
  final auth = ref.read(authProvider);
  final authStatus = ref.watch(authStatusProvider);
  
  if (authStatus != AuthStatus.authenticated) return null;
  
  final accessToken = await auth.getAccessToken(['User.Read']);
  if (accessToken == null) return null;

  final headers = {'Authorization': 'Bearer $accessToken'};

  final meUri = Uri.parse('https://graph.microsoft.com/v1.0/me');
  final photoUri = Uri.parse(
    'https://graph.microsoft.com/v1.0/me/photo/\$value',
  );

  final meFuture = http.get(meUri, headers: headers);
  final photoFuture = http.get(photoUri, headers: headers);

  final meResp = await meFuture;
  if (meResp.statusCode != 200) return null;

  Uint8List? photoBytes;
  final photoResp = await photoFuture;
  if (photoResp.statusCode == 200) {
    photoBytes = photoResp.bodyBytes;
  }

  final data = jsonDecode(meResp.body) as Map<String, dynamic>;

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
