// lib/screens/market_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart'; // To handle network images
import '../blocs/product_bloc.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_list_item.dart';
import '../widgets/empty_list_indicator.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  MarketPageState createState() => MarketPageState();
}

class MarketPageState extends State<MarketPage> {
  static const _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  late final ProductBloc _productBloc;
  Timer? _debounce;
  String _searchQuery = '';
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    final productRepository = Provider.of<ProductRepository>(context, listen: false);
    _productBloc = ProductBloc(repository: productRepository);

    _loadInitialProducts();

    // Listen to search input with a debounce
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _productBloc.close();
    super.dispose();
  }

  // Function to load products
  Future<void> _loadInitialProducts() async {
    final products = await _productBloc.repository.fetchProducts(page: 1, limit: _pageSize);
    setState(() {
      _products = products;
    });
  }

  // Pull-down-to-refresh handler
  Future<void> _onRefresh() async {
    setState(() {
      _products.clear(); // Clear current list
    });
    await _loadInitialProducts(); // Reload products
  }

  // Search function with debounce
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value.trim();
        _loadInitialProducts();
      });
    });
  }

  // Function to handle scrolling
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    final newProducts = await _productBloc.repository.fetchProducts(page: (_products.length / _pageSize).ceil() + 1, limit: _pageSize);
    setState(() {
      _products.addAll(newProducts);
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _showPincodeBottomSheet,
            child: const Text(
              'M1G1R2',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile icon tap
            },
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: CachedNetworkImage(
          imageUrl: 'https://your-image-url.com/image.jpg', // Replace with your actual image URL
          placeholder: (context, url) => Container(
            width: double.infinity,
            height: 150,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Text(
              'Failed to load image',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search items',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _loadInitialProducts();
                    });
                  },
                  tooltip: 'Clear Search',
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return const EmptyListIndicator();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductListItem(product: product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (context) => _productBloc,
      child: Scaffold(
        appBar: null,
        body: SafeArea(
          child: RefreshIndicator( // Pull-down-to-refresh functionality
            onRefresh: _onRefresh, // Handles the pull-down refresh
            child: SingleChildScrollView(
              controller: _scrollController, // Attach the scroll controller
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16.0),
                  _buildImageSection(),
                  const SizedBox(height: 16.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  _buildProductList(), // Product list is placed inside the scroll view
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle FAB tap, e.g., open a new action
          },
          tooltip: 'Cat Action',
          child: const Icon(Icons.pets),
        ),
      ),
    );
  }

  Future<void> _showPincodeBottomSheet() async {
    if (!mounted) return;

    String pincode = '';
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter Pincode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Pincode'),
                onChanged: (value) {
                  pincode = value;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (pincode.trim().isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pincode cannot be empty')),
                      );
                    }
                    return;
                  }
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('pincode', pincode);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pincode set to $pincode')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
