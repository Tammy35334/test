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

class SearchFlyersEvent extends FlyersEvent {
  final String query;

  const SearchFlyersEvent({required this.query});

  @override
  List<Object> get props => [query];
}
