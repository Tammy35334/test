// lib/storage/likes_storage_interface.dart

import '../models/like.dart';

abstract class LikesStorageInterface {
  Future<void> addLike(Like like);
  Future<void> removeLike(Like like);
  Future<List<Like>> getLikes();
}
