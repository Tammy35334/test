// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'market_page.dart';
import 'flyers_page.dart';
import 'shopping_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of widget pages to display
  static const List<Widget> _pages = <Widget>[
    MarketPage(),
    FlyersPage(),
    ShoppingListPage(),
    // ProfilePage(), // Optional: Uncomment if you have a ProfilePage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Optional: If you have a Floating Action Button for specific actions
  Widget? _buildFloatingActionButton() {
    // Example: Show FAB only on certain tabs
    if (_selectedIndex == 0) { // For MarketPage
      return FloatingActionButton(
        onPressed: () {
          // Handle FAB action, e.g., add a new product
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      );
    }
    // Return null to hide FAB on other tabs
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optionally, you can have a custom AppBar or none
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement), // Updated icon here
            label: 'Flyers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Shopping List',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: 'Profile',
          // ), // Optional: Uncomment if you have a ProfilePage
        ],
        type: BottomNavigationBarType.fixed, // To show all labels
      ),
    );
  }
}
