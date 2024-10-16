import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({Key? key, required this.product}) : super(key: key); // Added key parameter

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Image.network(
          product.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
        ),
        title: Text(
          product.name,
          style: TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          product.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
        trailing: Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.green),
        ),
        onTap: () {
          // Handle product tap, e.g., navigate to product details
        },
      ),
    );
  }
}
