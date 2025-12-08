import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:libkoala/libkoala.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_key_provider.g.dart';

@Riverpod(keepAlive: true)
Future<String> getApiKey(Ref ref) async {
  final Uri uri = Uri.https(
    'bearnet-key.vault.azure.net',
    '/secrets/bearnet-function-key',
    {'api-version': '7.4'},
  );

  final String? token = await ref.read(authProvider).getAccessToken(['https://vault.azure.net/user_impersonation']);

  final request = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  return jsonDecode(request.body)['value'];
}
