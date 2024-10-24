// lib/widgets/store_list_item.dart

import 'package:flutter/material.dart';
import '../models/store.dart';
import '../screens/flyer_detail_page.dart';

class StoreListItem extends StatelessWidget {
  final Store store;

  const StoreListItem({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        title: Text(
          store.storeName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(store.province),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (store.flyerImages.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlyerDetailPage(
                  flyerImages: store.flyerImages,
                  storeName: store.storeName,
                  storeId: store.storeId,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No flyers available for this store.')),
            );
          }
        },
      ),
    );
  }
}
