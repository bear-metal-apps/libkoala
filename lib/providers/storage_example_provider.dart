import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:sqflite/sqflite.dart';

part 'storage_example_provider.g.dart';

// Storage provider for riverpod_sqflite - this demonstrates the correct usage
@Riverpod(keepAlive: true)
Future<JsonSqFliteStorage> storage(Ref ref) async {
  final dbPath = await getDatabasesPath();
  return JsonSqFliteStorage.open(join(dbPath, 'libkoala.db'));
}