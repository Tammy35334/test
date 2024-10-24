// lib/models/metadata_storage.dart

import 'package:hive/hive.dart';

part 'metadata_storage.g.dart';

@HiveType(typeId: 4)
class Metadata extends HiveObject {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final String value;

  Metadata({required this.key, required this.value});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}
