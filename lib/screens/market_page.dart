// lib/screens/market_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  late final ProductRepository _productRepository;
  late final ProductBloc _productBloc;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _productRepository = ProductRepository(httpClient: http.Client());
    _productBloc = ProductBloc(repository: _productRepository);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await _productRepository.fetchProducts(page: pageKey, limit: _pageSize);
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
    _productRepository.httpClient.close();
    super.dispose();
  }

  Future<void> _showPincodeBottomSheet() async {
    String pincode = '';
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('pincode', pincode);
                  if (!mounted) return;
                  Navigator.pop(context);
                  if (mounted) {
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
    return Row(
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
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width * 0.95, // 95% of width
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Center(
        child: Text(
          'Image Placeholder',
          style: TextStyle(fontSize: 18, color: Colors.grey),
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
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Clear the search input
              _pagingController.refresh();
            },
            tooltip: 'Clear Search',
          ),
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
            // Implement search functionality based on 'value'
            _pagingController.refresh();
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
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTopBar(),
          const SizedBox(height: 16.0),
          _buildImageSection(),
          const SizedBox(height: 16.0),
          _buildSearchBar(),
          const SizedBox(height: 16.0),
          Expanded(child: _buildListView()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (context) => _productBloc,
      child: Scaffold(
        appBar: null, // Removed AppBar to integrate custom top bar within scrollable content
        body: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: _buildContent(),
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
