// lib/repositories/likes_repository.dart

import '../models/like.dart';
import '../storage/likes_storage_interface.dart';

class LikesRepository {
  final LikesStorageInterface storage;

  LikesRepository({required this.storage});

  Future<void> addLike(Like like) async {
    await storage.addLike(like);
  }

  Future<void> removeLike(Like like) async {
    await storage.removeLike(like);
  }

  Future<List<Like>> getLikes() async {
    return await storage.getLikes();
  }
}
