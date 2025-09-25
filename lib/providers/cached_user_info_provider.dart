import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:libkoala/providers/auth_provider.dart';
import 'package:libkoala/providers/database_provider.dart';
import 'package:libkoala/providers/user_info_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'cached_user_info_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UserInfo?> cachedUserInfo(Ref ref) async {
  final auth = ref.read(authProvider);
  final authStatus = ref.watch(authStatusProvider);
  final db = await ref.watch(databaseProvider.future);

  if (authStatus != AuthStatus.authenticated) return null;

  // Check cache first
  const cacheDurationHours = 24;
  final cacheValidUntil = DateTime.now().subtract(Duration(hours: cacheDurationHours));
  
  final List<Map<String, dynamic>> cached = await db.query(
    'user_info',
    where: 'updated_at > ?',
    whereArgs: [cacheValidUntil.millisecondsSinceEpoch],
    limit: 1,
  );

  if (cached.isNotEmpty) {
    final cachedData = cached.first;
    return UserInfo(
      name: cachedData['name'] as String?,
      email: cachedData['email'] as String?,
      photo: cachedData['photo'] != null ? cachedData['photo'] as Uint8List : null,
    );
  }

  // Cache miss - fetch from API
  final accessToken = await auth.accessToken ?? '';
  final headers = {'Authorization': 'Bearer $accessToken'};

  final meUri = Uri.parse('https://graph.microsoft.com/v1.0/me');
  final photoUri = Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value');

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
  final userInfo = UserInfo(
    name: data['displayName'] as String?,
    email: (data['mail'] ?? data['userPrincipalName']) as String?,
    photo: photoBytes,
  );

  // Cache the result
  await db.insert(
    'user_info',
    {
      'name': userInfo.name,
      'email': userInfo.email,
      'photo': userInfo.photo,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return userInfo;
}

/// Provider to clear cached user info (useful on logout)
@riverpod
Future<void> clearUserInfoCache(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  await db.delete('user_info');
}