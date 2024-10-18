// lib/models/like.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'like.g.dart';

@HiveType(typeId: 0)
class Like extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String storeName;

  @HiveField(2)
  final String imageId;

  @HiveField(3)
  final double x;

  @HiveField(4)
  final double y;

  Like({
    required this.id,
    required this.storeName,
    required this.imageId,
    required this.x,
    required this.y,
  });

  // Factory constructor to create a Like with a unique ID
  factory Like.create({
    required String storeName,
    required String imageId,
    required double x,
    required double y,
  }) {
    return Like(
      id: const Uuid().v4(),
      storeName: storeName,
      imageId: imageId,
      x: x,
      y: y,
    );
  }
}
