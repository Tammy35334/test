// lib/blocs/likes_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/like.dart';
import '../repositories/likes_repository.dart';
import '../utils/logger.dart';

part 'likes_event.dart';
part 'likes_state.dart';

class LikesBloc extends Bloc<LikesEvent, LikesState> {
  final LikesRepository repository;

  LikesBloc({required this.repository}) : super(LikesInitial()) {
    on<LoadLikesEvent>(_onLoadLikes);
    on<AddLikeEvent>(_onAddLike);
    on<RemoveLikeEvent>(_onRemoveLike);
  }

  Future<void> _onLoadLikes(LoadLikesEvent event, Emitter<LikesState> emit) async {
    try {
      logger.info('Loading likes...');
      final likes = await repository.getLikes();
      emit(LikesLoaded(likes: likes));
      logger.info('Loaded ${likes.length} likes.');
    } catch (e) {
      logger.severe('Error loading likes: $e');
      emit(LikesError(message: e.toString()));
    }
  }

  Future<void> _onAddLike(AddLikeEvent event, Emitter<LikesState> emit) async {
    if (state is LikesLoaded) {
      try {
        logger.info('Adding a like at (${event.like.x}, ${event.like.y}) for store ${event.like.storeName}.');
        await repository.addLike(event.like);
        final updatedLikes = List<Like>.from((state as LikesLoaded).likes)..add(event.like);
        emit(LikesLoaded(likes: updatedLikes));
        logger.info('Like added successfully.');
      } catch (e) {
        logger.severe('Error adding like: $e');
        emit(LikesError(message: e.toString()));
      }
    }
  }

  Future<void> _onRemoveLike(RemoveLikeEvent event, Emitter<LikesState> emit) async {
    if (state is LikesLoaded) {
      try {
        logger.info('Removing like at (${event.like.x}, ${event.like.y}) for store ${event.like.storeName}.');
        await repository.removeLike(event.like);
        final updatedLikes = List<Like>.from((state as LikesLoaded).likes)..remove(event.like);
        emit(LikesLoaded(likes: updatedLikes));
        logger.info('Like removed successfully.');
      } catch (e) {
        logger.severe('Error removing like: $e');
        emit(LikesError(message: e.toString()));
      }
    }
  }
}
