// lib/screens/flyer_detail_page.dart

import 'package:flutter/material.dart';

class FlyerDetailPage extends StatelessWidget {
  final List<String> flyerImages; // List of image URLs
  final String storeName;

  const FlyerDetailPage({super.key, required this.flyerImages, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        backgroundColor: Colors.white, // Match AppBar style with Flyers Page
        elevation: 0, // Remove AppBar shadow
        iconTheme: const IconThemeData(color: Colors.black), // Set icon color to black
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          color: Colors.black, // Set title color to black
        ),
      ),
      body: flyerImages.isNotEmpty
          ? ListView.builder(
              itemCount: flyerImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    flyerImages[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: Icon(Icons.error, color: Colors.red)),
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'No flyer images available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }
}
