// lib/models/metadata_storage.dart

import 'package:hive/hive.dart';

part 'metadata_storage.g.dart';

@HiveType(typeId: 4)
class Metadata extends HiveObject {
  @override
  @HiveField(0)
  final String key;

  @HiveField(1)
  final DateTime timestamp;

  Metadata({
    required this.key,
    required this.timestamp,
  });
}
