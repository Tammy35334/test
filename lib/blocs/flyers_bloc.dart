// lib/blocs/flyers_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/store.dart';
import '../repositories/flyers_repository.dart';
import '../utils/logger.dart';

part 'flyers_event.dart';
part 'flyers_state.dart';

class FlyersBloc extends Bloc<FlyersEvent, FlyersState> {
  final FlyersRepository repository;

  FlyersBloc({required this.repository}) : super(FlyersInitial()) {
    on<FetchFlyersEvent>(_onFetchFlyers);
    on<SearchFlyersEvent>(_onSearchFlyers);
  }

  Future<void> _onFetchFlyers(
      FetchFlyersEvent event, Emitter<FlyersState> emit) async {
    emit(FlyersLoading());
    try {
      final flyers = await repository.fetchFlyers();
      emit(FlyersLoaded(flyers: flyers));
    } catch (e) {
      logger.severe('Error fetching flyers: $e');
      emit(FlyersError(message: e.toString()));
    }
  }

  Future<void> _onSearchFlyers(
      SearchFlyersEvent event, Emitter<FlyersState> emit) async {
    emit(FlyersLoading());
    try {
      final flyers = await repository.searchFlyers(query: event.query);
      emit(FlyersLoaded(flyers: flyers));
    } catch (e) {
      logger.severe('Error searching flyers: $e');
      emit(FlyersError(message: e.toString()));
    }
  }
}
