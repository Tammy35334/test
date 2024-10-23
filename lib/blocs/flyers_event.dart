// lib/blocs/flyers_event.dart

part of 'flyers_bloc.dart';

abstract class FlyersEvent extends Equatable {
  const FlyersEvent();

  @override
  List<Object> get props => [];
}

class FetchFlyersEvent extends FlyersEvent {
  final int page;
  final int limit;

  const FetchFlyersEvent({required this.page, required this.limit});

  @override
  List<Object> get props => [page, limit];
}

class DeleteFlyerEvent extends FlyersEvent {
  final int id;

  const DeleteFlyerEvent({required this.id});

  @override
  List<Object> get props => [id];
}
