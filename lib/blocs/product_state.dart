// lib/blocs/product_state.dart

import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class ProductState extends Equatable {
  const ProductState(); // Added const constructor

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial(); // Added const constructor
}

class ProductLoading extends ProductState {
  const ProductLoading(); // Added const constructor
}

class ProductSuccess extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;

  const ProductSuccess({required this.products, required this.hasReachedMax});

  ProductSuccess copyWith({
    List<Product>? products,
    bool? hasReachedMax,
  }) {
    return ProductSuccess(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [products, hasReachedMax];
}

class ProductFailure extends ProductState {
  final String error;

  const ProductFailure({required this.error});

  @override
  List<Object> get props => [error];
}
