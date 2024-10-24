// lib/widgets/flyer_list_item.dart

import 'package:flutter/material.dart';
import '../models/store.dart';
import '../screens/flyer_detail_page.dart';

class FlyerListItem extends StatelessWidget {
  final Store flyer;

  const FlyerListItem({super.key, required this.flyer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        title: Text(
          flyer.storeName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(flyer.province),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlyerDetailPage(
                flyerImages: flyer.flyerImages,
                storeName: flyer.storeName,
                storeId: flyer.storeId,
              ),
            ),
          );
        },
      ),
    );
  }
}
