import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class Schemas {
  static Map<String, dynamic> getSchema(
    int year,
    int version,
    SchemaType type,
  ) {
    final file = File(
      p.join('schemas', '$year', '${version}_${type.name}.json'),
    );
    if (!file.existsSync()) {
      throw Exception('Schema file not found: ${file.path}');
    }
    return Map<String, dynamic>.from(jsonDecode(file.readAsStringSync()));
  }
}

enum SchemaType { match, strat }
