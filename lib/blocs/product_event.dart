// lib/blocs/product_event.dart

part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
}

class FetchProductsEvent extends ProductEvent {
  final int page;
  final int limit;
  final String? query;

  const FetchProductsEvent({required this.page, required this.limit, this.query});

  @override
  List<Object?> get props => [page, limit, query];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent({required this.query});

  @override
  List<Object> get props => [query];
}
