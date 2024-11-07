import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/emoji_reaction.dart';

class EmojiReactionManager {
  static const String _reactionsBoxName = 'emoji_reactions';
  Box<EmojiReaction>? _reactionsBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    if (!Hive.isBoxOpen(_reactionsBoxName)) {
      _reactionsBox = await Hive.openBox<EmojiReaction>(_reactionsBoxName);
    } else {
      _reactionsBox = Hive.box<EmojiReaction>(_reactionsBoxName);
    }
    _isInitialized = true;
  }

  Future<void> saveReaction(EmojiReaction reaction) async {
    await init();
    await _reactionsBox?.add(reaction);
  }

  Map<String, List<EmojiReaction>> getReactionsByStore() {
    final reactions = _reactionsBox?.values.toList() ?? [];
    return groupBy(reactions, (reaction) => reaction.storeId);
  }

  List<EmojiReaction> getReactionsForStore(String storeId) {
    return _reactionsBox?.values
        .where((reaction) => reaction.storeId == storeId)
        .toList() ?? [];
  }

  List<EmojiReaction> getReactionsForPage(String storeId, int pageNumber) {
    return _reactionsBox?.values
        .where((reaction) => 
            reaction.storeId == storeId && 
            reaction.pageNumber == pageNumber)
        .toList() ?? [];
  }

  Map<EmojiType, List<EmojiReaction>> getReactionsByType(String storeId) {
    final reactions = getReactionsForStore(storeId);
    return groupBy(reactions, (reaction) => reaction.emojiType);
  }

  double getAverageSentiment(String storeId) {
    final reactions = getReactionsForStore(storeId);
    if (reactions.isEmpty) return 0;
    
    final totalScore = reactions.fold<int>(
      0, 
      (sum, reaction) => sum + reaction.sentimentScore
    );
    return totalScore / reactions.length;
  }

  // Helper method to get normalized coordinates relative to the container
  Offset getNormalizedPosition(Offset position, Size containerSize, EdgeInsets padding) {
    final adjustedX = position.dx - padding.left;
    final adjustedY = position.dy - padding.top;
    
    return Offset(
      adjustedX / (containerSize.width - padding.horizontal),
      adjustedY / (containerSize.height - padding.vertical),
    );
  }

  // Helper method to get pixel coordinates from normalized coordinates
  Offset getPixelPosition(double xNorm, double yNorm, Size containerSize, EdgeInsets padding) {
    return Offset(
      xNorm * (containerSize.width - padding.horizontal) + padding.left,
      yNorm * (containerSize.height - padding.vertical) + padding.top,
    );
  }

  // Helper method to clear all reactions (useful for testing)
  Future<void> clearAllReactions() async {
    await init();
    await _reactionsBox?.clear();
  }
}

Map<K, List<V>> groupBy<K, V>(Iterable<V> items, K Function(V) key) {
  final map = <K, List<V>>{};
  for (final item in items) {
    final k = key(item);
    (map[k] ??= []).add(item);
  }
  return map;
}
