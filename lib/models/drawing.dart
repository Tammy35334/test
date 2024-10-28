import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'drawing.g.dart';

@HiveType(typeId: 3)
class Drawing extends HiveObject {
  @HiveField(0)
  final int storeId;

  @HiveField(1)
  final int pageIndex;

  @HiveField(2)
  final List<DrawingPoint> points;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DrawingPoint center;

  Drawing({
    required this.storeId,
    required this.pageIndex,
    required this.points,
    required this.center,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 4)
class DrawingPoint {
  @HiveField(0)
  final double x;

  @HiveField(1)
  final double y;

  DrawingPoint(this.x, this.y);

  factory DrawingPoint.fromOffset(Offset offset) {
    return DrawingPoint(offset.dx, offset.dy);
  }

  Offset toOffset() => Offset(x, y);
}
