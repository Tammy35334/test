// lib/screens/like_icon.dart

import 'package:flutter/material.dart';
import '../models/like.dart';

class LikeIcon extends StatefulWidget {
  final Like like;
  final TransformationController transformationController;
  final VoidCallback onRemove;

  const LikeIcon({
    super.key, // Converted to super parameter
    required this.like,
    required this.transformationController,
    required this.onRemove,
  });

  @override
  State<LikeIcon> createState() => _LikeIconState();
}

class _LikeIconState extends State<LikeIcon> with SingleTickerProviderStateMixin {
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    // Apply transformation to maintain position during zoom/pan
    final matrix = widget.transformationController.value;
    final transformedPosition = MatrixUtils.transformPoint(
      matrix,
      Offset(widget.like.x, widget.like.y),
    );

    return Positioned(
      left: transformedPosition.dx - 25, // Adjust for touch area
      top: transformedPosition.dy - 25,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent, // Allow gestures within the area
        onLongPress: () {
          _removeLike();
        },
        child: AnimatedScale(
          scale: _isRemoving ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          onEnd: () {
            if (_isRemoving) {
              widget.onRemove();
            }
          },
          child: AnimatedOpacity(
            opacity: _isRemoving ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 50, // Expanded touch area
              height: 50,
              alignment: Alignment.center,
              child: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removeLike() {
    setState(() {
      _isRemoving = true;
    });
  }
}
