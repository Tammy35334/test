// lib/storage/hive_likes_storage.dart

import 'package:hive/hive.dart';
import '../models/like.dart';
import 'likes_storage_interface.dart';

class HiveLikesStorage implements LikesStorageInterface {
  final Box<Like> _likesBox;

  HiveLikesStorage(this._likesBox);

  @override
  Future<void> addLike(Like like) async {
    await _likesBox.add(like);
  }

  @override
  Future<void> removeLike(Like like) async {
    final key = _likesBox.keys.firstWhere(
      (k) => _likesBox.get(k) == like,
      orElse: () => null,
    );
    if (key != null) {
      await _likesBox.delete(key);
    }
  }

  @override
  Future<List<Like>> getLikes() async {
    return _likesBox.values.toList();
  }
}
