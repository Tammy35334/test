import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/emoji_reaction.dart';

class EmojiReactionManager {
  static const String _reactionsBoxName = 'emoji_reactions';
  Box<EmojiReaction>? _reactionsBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_reactionsBoxName)) {
      _reactionsBox = await Hive.openBox<EmojiReaction>(_reactionsBoxName);
    }
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

  // Helper method to get a preview of the flyer image around a reaction
  Future<Image?> getReactionPreview(EmojiReaction reaction, Size pageSize) async {
    // TODO: Implement image preview extraction using the normalized coordinates
    // This will require access to the flyer images and proper coordinate transformation
    return null;
  }

  // Helper method to convert between screen and normalized coordinates
  Offset normalizeCoordinates(Offset screenPosition, Size pageSize, EdgeInsets padding) {
    // Account for padding and calculate normalized coordinates
    final adjustedX = screenPosition.dx - padding.left;
    final adjustedY = screenPosition.dy - padding.top;
    
    return Offset(
      adjustedX / (pageSize.width - padding.horizontal),
      adjustedY / (pageSize.height - padding.vertical),
    );
  }

  // Helper method to convert normalized coordinates back to screen position
  Offset denormalizeCoordinates(double xNorm, double yNorm, Size pageSize, EdgeInsets padding) {
    return Offset(
      xNorm * (pageSize.width - padding.horizontal) + padding.left,
      yNorm * (pageSize.height - padding.vertical) + padding.top,
    );
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
