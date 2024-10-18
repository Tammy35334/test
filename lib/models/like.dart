// lib/models/like.dart

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'like.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class Like {
  @HiveField(0)
  final String storeName;

  @HiveField(1)
  final String imageId; // Unique identifier for the image

  @HiveField(2)
  final double x; // X-coordinate of the like
  @HiveField(3)
  final double y; // Y-coordinate of the like

  Like({
    required this.storeName,
    required this.imageId,
    required this.x,
    required this.y,
  });

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);

  Map<String, dynamic> toJson() => _$LikeToJson(this);
}
