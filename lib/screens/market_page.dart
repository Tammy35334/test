// lib/screens/market_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/cupertino.dart'; // For iOS-like widgets

import '../blocs/product_bloc.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_list_item.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/error_indicator.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  MarketPageState createState() => MarketPageState();
}

class MarketPageState extends State<MarketPage> {
  Timer? _debounce;
  String _searchQuery = '';

  late final ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    final productRepository = Provider.of<ProductRepository>(context, listen: false);
    _productBloc = ProductBloc(repository: productRepository);
    // Load cached products if available
    _loadCachedProducts();
  }

  Future<void> _loadCachedProducts() async {
    final cachedProducts = await _productBloc.repository.getCachedProducts();
    if (cachedProducts.isNotEmpty) {
      _productBloc.pagingController.appendLastPage(cachedProducts);
    } else {
      _productBloc.pagingController.refresh();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _productBloc.close();
    super.dispose();
  }

  // Pull-down-to-refresh handler
  Future<void> _onRefresh() async {
    _productBloc.pagingController.refresh();
  }

  // Search function with debounce
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _productBloc.add(SearchProductsEvent(query: value.trim()));
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      child: CupertinoSearchTextField(
        controller: TextEditingController(text: _searchQuery),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _onSearchChanged(value);
        },
        onSubmitted: (value) {
          _productBloc.add(SearchProductsEvent(query: value.trim()));
        },
        onSuffixTap: () {
          setState(() {
            _searchQuery = '';
          });
          _onSearchChanged('');
        },
        placeholder: 'Search items',
      ),
    );
  }

  Widget _buildProductList() {
    return PagedSliverList<int, Product>(
      pagingController: _productBloc.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Product>(
        itemBuilder: (context, item, index) => ProductListItem(product: item),
        firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
          error: (_productBloc.pagingController.error as Exception).toString(),
          onTryAgain: () => _productBloc.pagingController.refresh(),
        ),
        noItemsFoundIndicatorBuilder: (context) => const EmptyListIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (context) => _productBloc,
      child: Scaffold(
        appBar: null,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar()),
                SliverToBoxAdapter(child: SizedBox(height: 8.0)),
                SliverToBoxAdapter(child: _buildImageSection()),
                SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                _buildProductList(),
              ],
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
                onSubmitted: (value) async {
                  await _savePincode(value.trim());
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
                  await _savePincode(pincode.trim());
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePincode(String pincode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pincode', pincode);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pincode set to $pincode')),
    );
  }
}
