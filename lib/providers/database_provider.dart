import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Database> database(Ref ref) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'libkoala.db');
  
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create user_info table for caching user data
      await db.execute('''
        CREATE TABLE user_info (
          id INTEGER PRIMARY KEY,
          name TEXT,
          email TEXT,
          photo BLOB,
          updated_at INTEGER
        )
      ''');
    },
  );
}