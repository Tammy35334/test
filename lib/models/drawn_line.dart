// lib/models/drawn_line.dart

import 'package:hive/hive.dart';

part 'drawn_line.g.dart';

@HiveType(typeId: 2)
class DrawnLine extends HiveObject {
  @HiveField(0)
  final List<double> points; // Stored as a flat list [x1, y1, x2, y2, ...]

  DrawnLine({required this.points});

  factory DrawnLine.fromJson(Map<String, dynamic> json) {
    return DrawnLine(
      points: List<double>.from(json['points']),
    );
  }

  Map<String, dynamic> toJson() => {
        'points': points,
      };
}
