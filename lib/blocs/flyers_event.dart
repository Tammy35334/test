// lib/blocs/flyers_event.dart

part of 'flyers_bloc.dart';

abstract class FlyersEvent extends Equatable {
  const FlyersEvent();

  @override
  List<Object> get props => [];
}

class FetchFlyersEvent extends FlyersEvent {
  const FetchFlyersEvent();
}

class DeleteFlyerEvent extends FlyersEvent {
  final int id;

  const DeleteFlyerEvent({required this.id});

  @override
  List<Object> get props => [id];
}
