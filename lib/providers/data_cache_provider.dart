import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:libkoala/providers/database_provider.dart';

part 'data_cache_provider.g.dart';

/// Example of using sqflite with Riverpod for generic data caching
/// This demonstrates the integration in a simple way
@riverpod
class DataCache extends _$DataCache {
  @override
  Future<Map<String, dynamic>> build() async {
    return {};
  }

  /// Cache a key-value pair with current timestamp
  Future<void> setCache(String key, String value) async {
    final db = await ref.watch(databaseProvider.future);
    
    // First, create the cache table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_cache (
        key TEXT PRIMARY KEY,
        value TEXT,
        timestamp INTEGER
      )
    ''');
    
    await db.insert(
      'app_cache',
      {
        'key': key,
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Update state to notify listeners
    state = AsyncValue.data({...state.value ?? {}, key: value});
  }

  /// Get a cached value by key
  Future<String?> getCache(String key) async {
    final db = await ref.watch(databaseProvider.future);
    final result = await db.query(
      'app_cache',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    final db = await ref.watch(databaseProvider.future);
    await db.delete('app_cache');
    state = const AsyncValue.data({});
  }
}