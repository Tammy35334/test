// lib/blocs/product_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../utils/logger.dart';

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
      final products = await repository.fetchProducts();
      emit(ProductLoaded(products: products));
    } catch (e, stacktrace) {
      logger.severe('Error fetching products: $e', e, stacktrace);
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onSearchProducts(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await repository.searchProducts(query: event.query);
      emit(ProductLoaded(products: products));
    } catch (e, stacktrace) {
      logger.severe('Error searching products: $e', e, stacktrace);
      emit(ProductError(message: e.toString()));
    }
  }
}
