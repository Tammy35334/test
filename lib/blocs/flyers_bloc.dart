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
    on<DeleteFlyerEvent>(_onDeleteFlyer);
  }

  Future<void> _onFetchFlyers(
      FetchFlyersEvent event, Emitter<FlyersState> emit) async {
    emit(FlyersLoading());
    try {
      final flyers = await repository.fetchFlyers();
      emit(FlyersLoaded(flyers: flyers));
    } catch (e, stacktrace) {
      logger.severe('Error fetching flyers: $e', e, stacktrace);
      emit(FlyersError(message: e.toString()));
    }
  }

  Future<void> _onDeleteFlyer(
      DeleteFlyerEvent event, Emitter<FlyersState> emit) async {
    try {
      await repository.deleteFlyer(event.id);
      emit(FlyerDeleted(id: event.id));
      // Optionally refetch the flyers
      add(FetchFlyersEvent());
    } catch (e, stacktrace) {
      logger.severe('Error deleting flyer: $e', e, stacktrace);
      emit(FlyersError(message: e.toString()));
    }
  }
}
