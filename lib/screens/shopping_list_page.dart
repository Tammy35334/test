// lib/screens/shopping_list_page.dart

import 'package:flutter/material.dart';
import '../widgets/error_indicator.dart';
import '../widgets/empty_list_indicator.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for ShoppingListPage implementation
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(fontFamily: 'Roboto', fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile icon tap
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Shopping List Page Content',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB tap
        },
        child: const Icon(Icons.pets), // Cat icon
        tooltip: 'Cat Action',
      ),
    );
  }
}
