// lib/blocs/product_event.dart

part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
}

class FetchProductsEvent extends ProductEvent {
  const FetchProductsEvent();

  @override
  List<Object?> get props => [];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent({required this.query});

  @override
  List<Object> get props => [query];
}
