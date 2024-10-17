// lib/blocs/product_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  final PagingController<int, Product> pagingController;

  ProductBloc({required this.repository})
      : pagingController = PagingController(firstPageKey: 1),
        super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    pagingController.addPageRequestListener((pageKey) {
      add(FetchProductsEvent(page: pageKey, limit: _pageSize, query: currentQuery));
    });
  }

  String currentQuery = '';

  Future<void> _onFetchProducts(
      FetchProductsEvent event, Emitter<ProductState> emit) async {
    try {
      final products = await repository.fetchProducts(
        page: event.page,
        limit: event.limit,
        query: event.query,
      );
      final isLastPage = products.length < event.limit;
      if (isLastPage) {
        pagingController.appendLastPage(products);
      } else {
        final nextPageKey = event.page + 1;
        pagingController.appendPage(products, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onSearchProducts(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    currentQuery = event.query;
    pagingController.refresh();
  }

  static const int _pageSize = 20;

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
