import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http; // Added import for http
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_list_item.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({Key? key}) : super(key: key); // Added key parameter

  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  static const _pageSize = 20;

  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 1);

  late ProductRepository _productRepository;
  late ProductBloc _productBloc;

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
      // Fetch products using BLoC
      _productBloc.add(FetchProducts());

      // Listen to the BLoC state
      final subscription = _productBloc.stream.listen((state) {
        if (state is ProductSuccess) {
          final isLastPage = state.hasReachedMax;
          if (isLastPage) {
            _pagingController.appendLastPage(state.products);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(state.products, nextPageKey);
          }
        } else if (state is ProductFailure) {
          _pagingController.error = state.error;
        }
      });

      // Allow some time for the BLoC to emit the state
      await Future.delayed(Duration(milliseconds: 500));

      await subscription.cancel();
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _productBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (context) => _productBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Market',
            style: TextStyle(fontFamily: 'Roboto', fontSize: 24),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
          ),
          child: PagedListView<int, Product>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Product>(
              itemBuilder: (context, item, index) => ProductListItem(product: item),
              firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                error: _pagingController.error.toString(),
                onTryAgain: () => _pagingController.refresh(),
              ),
              noItemsFoundIndicatorBuilder: (context) => EmptyListIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Widgets for Error and Empty States

class ErrorIndicator extends StatelessWidget {
  final String error;
  final VoidCallback onTryAgain;

  const ErrorIndicator({Key? key, required this.error, required this.onTryAgain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $error'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: onTryAgain,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class EmptyListIndicator extends StatelessWidget {
  const EmptyListIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No products found.'),
    );
  }
}
