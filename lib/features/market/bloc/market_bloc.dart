import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/models/product.dart';

// Events
abstract class MarketEvent {}

class LoadProducts extends MarketEvent {}
class SearchProducts extends MarketEvent {
  final String query;
  SearchProducts(this.query);
}

// States
abstract class MarketState {}

class MarketInitial extends MarketState {}
class MarketLoading extends MarketState {}
class MarketLoaded extends MarketState {
  final List<Product> products;
  MarketLoaded(this.products);
}
class MarketError extends MarketState {
  final String message;
  MarketError(this.message);
}

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final ApiService _apiService;
  final CacheService _cacheService;

  MarketBloc(this._apiService, this._cacheService) : super(MarketInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketLoading());
    try {
      // First try to get cached data
      final cachedProducts = await _cacheService.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        emit(MarketLoaded(cachedProducts));
      }

      // Then fetch fresh data
      final products = await _apiService.fetchProducts();
      await _cacheService.cacheProducts(products);
      emit(MarketLoaded(products));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<MarketState> emit,
  ) async {
    // Implementation for search functionality
  }
}
