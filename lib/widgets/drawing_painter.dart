import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  DrawingPainter({
    required this.strokes,
    this.color = Colors.red,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      
      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);
      
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
           color != oldDelegate.color ||
           strokeWidth != oldDelegate.strokeWidth;
  }
}
