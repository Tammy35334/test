import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  static const int _limit = 20; // Number of products per page

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoading) return;

    final currentState = state;

    List<Product> products = [];
    if (currentState is ProductSuccess) {
      products = currentState.products;
      if (currentState.hasReachedMax) {
        return;
      }
    }

    emit(ProductLoading());

    try {
      final nextPage = (products.length / _limit).ceil() + 1;
      final fetchedProducts = await repository.fetchProducts(page: nextPage, limit: _limit);

      final hasReachedMax = fetchedProducts.length < _limit;
      products = List.of(products)..addAll(fetchedProducts);

      emit(ProductSuccess(products: products, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(ProductFailure(error: e.toString()));
    }
  }
}
