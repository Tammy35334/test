// lib/blocs/flyers_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/store.dart';
import '../repositories/flyers_repository.dart';
import '../utils/logger.dart'; // Import the  logger

part 'flyers_event.dart';
part 'flyers_state.dart';

class FlyersBloc extends Bloc<FlyersEvent, FlyersState> {
  final FlyersRepository repository;
  final PagingController<int, Store> pagingController;

  // Define the page size
  static const int _pageSize = 20;

  FlyersBloc({required this.repository})
      : pagingController = PagingController(firstPageKey: 0),
        super(FlyersInitial()) {
    on<FetchFlyersEvent>(_onFetchFlyers);
    pagingController.addPageRequestListener((pageKey) {
      add(FetchFlyersEvent(page: pageKey, limit: _pageSize));
    });
  }

  Future<void> _onFetchFlyers(FetchFlyersEvent event, Emitter<FlyersState> emit) async {
    try {
      logger.info('Fetching page ${event.page} with limit ${event.limit}');

      // Fetch all flyers once
      final allFlyers = await repository.fetchAllFlyers();
      logger.info('Fetched ${allFlyers.length} flyers.');

      // Implement local pagination
      final int startIndex = event.page * event.limit;
      if (startIndex >= allFlyers.length) {
        pagingController.appendLastPage([]);
        emit(FlyersLoaded(flyers: [], hasReachedMax: true));
        logger.warning('No more flyers to load.');
        return;
      }

      final int endIndex = startIndex + event.limit;
      final isLastPage = endIndex >= allFlyers.length;
      final newItems = isLastPage
          ? allFlyers.sublist(startIndex, allFlyers.length)
          : allFlyers.sublist(startIndex, endIndex);

      logger.info('Appending page ${event.page}: ${newItems.length} items.');

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = event.page + 1;
        pagingController.appendPage(newItems, nextPageKey);
      }

      emit(FlyersLoaded(flyers: newItems, hasReachedMax: isLastPage));
    } catch (e) {
      logger.severe('Error fetching flyers: $e');
      pagingController.error = e;
      emit(FlyersError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
