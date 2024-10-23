// lib/blocs/flyers_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/store.dart';
import '../repositories/flyers_repository.dart';
import '../utils/logger.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'flyers_event.dart';
part 'flyers_state.dart';

class FlyersBloc extends Bloc<FlyersEvent, FlyersState> {
  final FlyersRepository repository;
  final PagingController<int, Store> pagingController;

  FlyersBloc({required this.repository})
      : pagingController = PagingController(firstPageKey: 1),
        super(FlyersInitial()) {
    on<FetchFlyersEvent>(_onFetchFlyers);
    on<DeleteFlyerEvent>(_onDeleteFlyer);

    pagingController.addPageRequestListener((pageKey) {
      add(FetchFlyersEvent(page: pageKey, limit: 20));
    });
  }

  Future<void> _onFetchFlyers(
      FetchFlyersEvent event, Emitter<FlyersState> emit) async {
    try {
      // Fetch flyers from repository
      final flyers = await repository.fetchFlyers(page: event.page, limit: event.limit);
      final bool isLastPage = flyers.length < event.limit;

      if (isLastPage) {
        pagingController.appendLastPage(flyers);
      } else {
        final nextPageKey = event.page + 1;
        pagingController.appendPage(flyers, nextPageKey);
      }

      emit(FlyersLoaded(flyers: flyers, hasReachedMax: isLastPage));
    } catch (e, stacktrace) {
      logger.severe('Error fetching flyers: $e', e, stacktrace);
      pagingController.error = e;
      emit(FlyersError(message: e.toString()));
    }
  }

  Future<void> _onDeleteFlyer(
      DeleteFlyerEvent event, Emitter<FlyersState> emit) async {
    try {
      await repository.deleteFlyer(event.id);
      emit(FlyersDeleted());
      // Refresh the current page
      pagingController.refresh();
    } catch (e, stacktrace) {
      logger.severe('Error deleting flyer: $e', e, stacktrace);
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
