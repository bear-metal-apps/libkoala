import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:libkoala/providers/auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_info_provider.g.dart';

@riverpod
Future<UserInfo> userInfo(Ref ref) async {
  final auth = ref.watch(authProvider);
  return UserInfo(
    endpoint: 'https://graph.microsoft.com/v1.0/me',
    accessToken: await auth.accessToken ?? '',
  );
}

class UserInfo {
  final String endpoint;
  final String accessToken;

  UserInfo({required this.endpoint, required this.accessToken});

  Future<Map<String, dynamic>> _fetch() async {
    if (accessToken.isEmpty) return {};
    final resp = await http.get(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<String?> get name async {
    final data = await _fetch();
    return data['displayName'] as String?;
  }

  Future<String?> get email async {
    final data = await _fetch();
    return (data['mail'] ?? data['userPrincipalName']) as String?;
  }

  Future<Uint8List?> get profilePhoto async {
    if (accessToken.isEmpty) return null;
    final resp = await http.get(
      Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (resp.statusCode == 200) {
      return resp.bodyBytes;
    }
    return null;
  }
}
