import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../repositories/flyer_repository.dart';

class HiveCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const HiveCachedImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: context.read<FlyerRepository>().getImageBytes(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Icon(Icons.error));
        }

        return Image.memory(
          snapshot.data!,
          fit: fit ?? BoxFit.cover,
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          filterQuality: FilterQuality.high,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: child,
            );
          },
        );
      },
    );
  }
}
