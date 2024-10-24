// lib/blocs/flyers_state.dart

part of 'flyers_bloc.dart';

abstract class FlyersState extends Equatable {
  const FlyersState();

  @override
  List<Object> get props => [];
}

class FlyersInitial extends FlyersState {}

class FlyersLoading extends FlyersState {}

class FlyersLoaded extends FlyersState {
  final List<Store> flyers;

  const FlyersLoaded({required this.flyers});

  @override
  List<Object> get props => [flyers];
}

class FlyersError extends FlyersState {
  final String message;

  const FlyersError({required this.message});

  @override
  List<Object> get props => [message];
}
