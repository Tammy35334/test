// lib/blocs/product_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<SearchProductsEvent>(_onSearchProducts);
  }

  Future<void> _onFetchProducts(
      FetchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProducts(
        page: event.page,
        limit: event.limit,
        query: event.query,
      );
      emit(ProductLoaded(
          products: products, hasReachedMax: products.length < event.limit));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onSearchProducts(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProducts(
        page: 1,
        limit: _pageSize,
        query: event.query,
      );
      emit(ProductLoaded(
          products: products, hasReachedMax: products.length < _pageSize));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  static const int _pageSize = 20;
}
