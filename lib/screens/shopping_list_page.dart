// lib/screens/shopping_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product_bloc.dart';
import '../widgets/product_list_item.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/error_indicator.dart';
import '../repositories/product_repository.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ShoppingListPageState createState() => ShoppingListPageState();
}

class ShoppingListPageState extends State<ShoppingListPage> {
  late final ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = ProductBloc(
        repository: RepositoryProvider.of<ProductRepository>(context));
    _productBloc.add(const FetchProductsEvent());
  }

  @override
  void dispose() {
    _productBloc.close();
    super.dispose();
  }

  // Pull-down-to-refresh handler
  Future<void> _onRefresh() async {
    _productBloc.add(const FetchProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (context) => _productBloc,
      child: Scaffold(
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
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoaded) {
                  if (state.products.isEmpty) {
                    return const EmptyListIndicator();
                  }
                  return ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return ProductListItem(product: state.products[index]);
                    },
                  );
                } else if (state is ProductError) {
                  return ErrorIndicator(
                    error: state.message,
                    onTryAgain: () =>
                        _productBloc.add(const FetchProductsEvent()),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle FAB tap, e.g., add a new product
          },
          tooltip: 'Add Product',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
