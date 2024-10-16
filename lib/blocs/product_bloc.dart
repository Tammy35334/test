// lib/blocs/product_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../repositories/product_repository.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  static const int _limit = 20;

  ProductBloc({required this.repository}) : super(const ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(
      FetchProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoading) return;

    try {
      emit(const ProductLoading());

      // Fetch the first page of products
      final products = await repository.fetchProducts(page: 1, limit: _limit);
      final hasReachedMax = products.length < _limit;

      emit(ProductSuccess(products: products, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(ProductFailure(error: e.toString()));
    }
  }
}
