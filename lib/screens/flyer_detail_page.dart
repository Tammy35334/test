// lib/screens/flyer_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FlyerDetailPage extends StatelessWidget {
  final List<String> flyerImages; // List of flyer image URLs
  final String storeName;
  final int storeId; // Changed from imageId to storeId

  const FlyerDetailPage({
    super.key,
    required this.flyerImages,
    required this.storeName,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$storeName Flyers',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: flyerImages.isNotEmpty
          ? PageView.builder(
              itemCount: flyerImages.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20.0),
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: CachedNetworkImage(
                    imageUrl: flyerImages[index],
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                    fit: BoxFit.contain,
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'No flyers available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
    );
  }
}
