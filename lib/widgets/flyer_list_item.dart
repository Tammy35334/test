// lib/widgets/flyer_list_item.dart

import 'package:flutter/material.dart';
import '../models/store.dart';
import '../repositories/flyers_repository.dart';
import 'package:provider/provider.dart';

class FlyerListItem extends StatefulWidget {
  final Store flyer;

  const FlyerListItem({super.key, required this.flyer});

  @override
  _FlyerListItemState createState() => _FlyerListItemState();
}

class _FlyerListItemState extends State<FlyerListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.flyer.storeName),
      subtitle: Text(widget.flyer.province),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          try {
            await Provider.of<FlyersRepository>(context, listen: false)
                .deleteFlyer(widget.flyer.storeId); // Pass int storeId
            if (!mounted) return; // Ensure widget is still mounted
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Flyer deleted successfully')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting flyer: $e')),
            );
          }
        },
      ),
      onTap: () {
        // Navigate to flyer details or perform other actions
      },
    );
  }
}
