import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import '../bloc/market_bloc.dart';
import '../../../core/models/product.dart'; 
import 'product_detail_screen.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SearchBarDelegate(),
            floating: true,
          ),
          BlocBuilder<MarketBloc, MarketState>(
            builder: (context, state) {
              if (state is MarketLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is MarketLoaded) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = state.products[index];
                      return ProductListItem(product: product);
                    },
                    childCount: state.products.length,
                  ),
                );
              }
              if (state is MarketError) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                );
              }
              return const SliverFillRemaining(child: SizedBox());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const PostalCodeWidget(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8.0),
      child: const SearchBar(),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        context.read<MarketBloc>().add(SearchProducts(value));
      },
    );
  }
}

class PostalCodeWidget extends StatelessWidget {
  const PostalCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.location_on),
      label: const Text('M1M 1M1'),
      onPressed: () {
        // Show postal code change dialog
      },
    );
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: 'product_${product.id}',
        child: CachedNetworkImage(
          imageUrl: product.imageUrl,
          width: 50,
          height: 50,
          placeholder: (context, url) => const SizedBox(
            width: 50,
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
      title: Text(product.name),
      subtitle: Text('From ${_getLowestPrice(product.storePrices)}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
    );
  }

  String _getLowestPrice(Map<String, double> prices) {
    if (prices.isEmpty) return 'N/A';
    return '\$${prices.values.reduce(min).toStringAsFixed(2)}';
  }
}
