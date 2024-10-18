// lib/models/drawing.dart

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'drawing.g.dart';

@HiveType(typeId: 3) // Ensure unique typeId
class Drawing extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imageId;

  @HiveField(2)
  final double centerX;

  @HiveField(3)
  final double centerY;

  Drawing({
    required this.id,
    required this.imageId,
    required this.centerX,
    required this.centerY,
  });

  Offset get center => Offset(centerX, centerY);
}
