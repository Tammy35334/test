// lib/blocs/likes_event.dart

part of 'likes_bloc.dart';

abstract class LikesEvent extends Equatable {
  const LikesEvent();

  @override
  List<Object?> get props => [];
}

class LoadLikesEvent extends LikesEvent {}

class AddLikeEvent extends LikesEvent {
  final Like like;

  const AddLikeEvent({required this.like});

  @override
  List<Object?> get props => [like];
}

class RemoveLikeEvent extends LikesEvent {
  final Like like;

  const RemoveLikeEvent({required this.like});

  @override
  List<Object?> get props => [like];
}
