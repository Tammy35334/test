import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'emoji_reaction.g.dart';

@HiveType(typeId: 5)
enum EmojiType {
  @HiveField(0)
  heart, // ❤️ Score: 4
  @HiveField(1)
  thumbsUp, // 👍 Score: 3
  @HiveField(2)
  neutral, // 😐 Score: 2
  @HiveField(3)
  thumbsDown, // 👎 Score: 1
}

@HiveType(typeId: 6)
class EmojiReaction extends HiveObject {
  @HiveField(0)
  final String storeId; // Changed from int to String

  @HiveField(1)
  final int pageNumber;

  @HiveField(2)
  final double xNorm; // Normalized x coordinate (0.0 to 1.0)

  @HiveField(3)
  final double yNorm; // Normalized y coordinate (0.0 to 1.0)

  @HiveField(4)
  final EmojiType emojiType;

  @HiveField(5)
  final DateTime createdAt;

  EmojiReaction({
    required this.storeId,
    required this.pageNumber,
    required this.xNorm,
    required this.yNorm,
    required this.emojiType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get emojiChar {
    switch (emojiType) {
      case EmojiType.heart:
        return '❤️';
      case EmojiType.thumbsUp:
        return '👍';
      case EmojiType.neutral:
        return '😐';
      case EmojiType.thumbsDown:
        return '👎';
    }
  }

  int get sentimentScore {
    switch (emojiType) {
      case EmojiType.heart:
        return 4;
      case EmojiType.thumbsUp:
        return 3;
      case EmojiType.neutral:
        return 2;
      case EmojiType.thumbsDown:
        return 1;
    }
  }

  // Convert normalized coordinates to actual pixel coordinates
  Offset getPixelPosition(Size pageSize) {
    return Offset(
      xNorm * pageSize.width,
      yNorm * pageSize.height,
    );
  }

  // Create from pixel coordinates
  static EmojiReaction fromPixelPosition({
    required String storeId, // Changed from int to String
    required int pageNumber,
    required Offset position,
    required Size pageSize,
    required EmojiType emojiType,
  }) {
    return EmojiReaction(
      storeId: storeId,
      pageNumber: pageNumber,
      xNorm: position.dx / pageSize.width,
      yNorm: position.dy / pageSize.height,
      emojiType: emojiType,
    );
  }
}
