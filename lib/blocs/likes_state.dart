// lib/blocs/likes_state.dart

part of 'likes_bloc.dart';

abstract class LikesState extends Equatable {
  const LikesState();

  @override
  List<Object?> get props => [];
}

class LikesInitial extends LikesState {}

class LikesLoaded extends LikesState {
  final List<Like> likes;

  const LikesLoaded({required this.likes});

  @override
  List<Object?> get props => [likes];
}

class LikesError extends LikesState {
  final String message;

  const LikesError({required this.message});

  @override
  List<Object?> get props => [message];
}
