// lib/screens/market_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart'; // To handle network images

import '../blocs/product_bloc.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_list_item.dart';
import '../widgets/error_indicator.dart';
import '../widgets/empty_list_indicator.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  MarketPageState createState() => MarketPageState();
}

class MarketPageState extends State<MarketPage> {
  static const _pageSize = 20;

  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 1);

  late final ProductBloc _productBloc;
  Timer? _debounce;
  String _searchQuery = '';
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    final productRepository = Provider.of<ProductRepository>(context, listen: false);
    _productBloc = ProductBloc(repository: productRepository);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!mounted) return;
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
      if (_isConnected) {
        _pagingController.refresh();
      }
    });

    // Load cached data initially
    _loadCachedData();
  }

  void _loadCachedData() async {
    final cachedProducts = await _productBloc.repository.getCachedProducts();
    if (cachedProducts.isNotEmpty) {
      if (!mounted) return;
      _pagingController.appendPage(cachedProducts, 2);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    if (!_isConnected) {
      // Inform the user about offline status
      _pagingController.error = 'No internet connection';
      return;
    }

    try {
      final newItems = await _productBloc.repository.fetchProducts(
        page: pageKey,
        limit: _pageSize,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      debugPrint('Error fetching products: $error');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pagingController.dispose();
    _productBloc.close();
    super.dispose();
  }

  Future<void> _showPincodeBottomSheet() async {
    String pincode = '';
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter Pincode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Pincode',
                ),
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
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pincode set to $pincode')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
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
        height: 200, // Adjusted height for better layout
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Network image with placeholder and error handling
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
                      _pagingController.refresh();
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
        onChanged: (value) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            setState(() {
              _searchQuery = value.trim();
              _pagingController.refresh();
            });
          });
        },
      ),
    );
  }

  Widget _buildListView() {
    return PagedListView<int, Product>(
      pagingController: _pagingController,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      builderDelegate: PagedChildBuilderDelegate<Product>(
        itemBuilder: (context, item, index) => ProductListItem(product: item),
        firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
          error: _pagingController.error?.toString() ?? 'Unknown error',
          onTryAgain: () => _pagingController.refresh(),
        ),
        noItemsFoundIndicatorBuilder: (context) => const EmptyListIndicator(),
        newPageErrorIndicatorBuilder: (context) => ErrorIndicator(
          error: _pagingController.error?.toString() ?? 'Unknown error',
          onTryAgain: () => _pagingController.retryLastFailedRequest(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (context) => _productBloc,
      child: Scaffold(
        appBar: null, // Removed AppBar to integrate custom top bar within scrollable content
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: SingleChildScrollView(  // Use SingleChildScrollView to make the whole page scrollable
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16.0),
                  _buildImageSection(),
                  const SizedBox(height: 16.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  _buildListView(),  // This will scroll inside the SingleChildScrollView
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
          child: const Icon(Icons.pets), // Cat icon
        ),
      ),
    );
  }
}
