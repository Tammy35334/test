// lib/widgets/store_list_item.dart

import 'package:flutter/material.dart';
import '../models/store.dart';
import '../screens/flyer_detail_page.dart';

class StoreListItem extends StatelessWidget {
  final Store store;

  const StoreListItem({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Removed leading image
      title: Text(
        store.storeName,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
      subtitle: Text(
        store.province,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black54,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16.0,
        color: Colors.grey,
      ),
      onTap: () {
        if (store.flyerImages.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlyerDetailPage(
                flyerImages: store.flyerImages, // Passing the list of images
                storeName: store.storeName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No flyer images available for this store.')),
          );
        }
      },
    );
  }
}
