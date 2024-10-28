import 'package:flutter/material.dart';
import 'dart:typed_data';

class OptimizedFlyerImage extends StatefulWidget {
  final Uint8List imageBytes;
  final BoxFit? fit;

  const OptimizedFlyerImage({
    super.key,
    required this.imageBytes,
    this.fit,
  });

  @override
  State<OptimizedFlyerImage> createState() => _OptimizedFlyerImageState();
}

class _OptimizedFlyerImageState extends State<OptimizedFlyerImage> {
  late final Image _image;

  @override
  void initState() {
    super.initState();
    _image = Image.memory(
      widget.imageBytes,
      fit: widget.fit ?? BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_image.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return _image;
  }
}
