import 'package:flutter/material.dart';

class FlyerViewStyles {
  static const double minScale = 1.0;
  static const double maxScale = 4.0;
  static const double defaultScale = 1.0;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
  
  static const EdgeInsets pagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets indicatorPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
}
