import 'package:flutter/material.dart';
import '../models/emoji_reaction.dart';

class EmojiReactionOverlay extends StatelessWidget {
  final Offset position;
  final Function(EmojiType) onEmojiSelected;

  const EmojiReactionOverlay({
    Key? key,
    required this.position,
    required this.onEmojiSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx - 100,
          top: position.dy - 50,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: EmojiType.values.map((type) {
                  final emoji = EmojiReaction(
                    storeId: "0", // Changed from int to String
                    pageNumber: 0,
                    xNorm: 0,
                    yNorm: 0,
                    emojiType: type,
                  ).emojiChar;

                  return InkWell(
                    onTap: () => onEmojiSelected(type),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
