import 'package:flutter/material.dart';
import '../models/emoji_reaction.dart';

class EmojiReactionsBottomSheet extends StatelessWidget {
  final Map<EmojiType, List<EmojiReaction>> reactions;
  final Function(EmojiReaction) onReactionSelected;

  const EmojiReactionsBottomSheet({
    Key? key,
    required this.reactions,
    required this.onReactionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: EmojiType.values.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: EmojiType.values.map((type) {
                final emoji = EmojiReaction(
                  storeId: "0", // Changed from int to String
                  pageNumber: 0,
                  xNorm: 0,
                  yNorm: 0,
                  emojiType: type,
                ).emojiChar;

                return Tab(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: TabBarView(
              children: EmojiType.values.map((type) {
                final typeReactions = reactions[type] ?? [];
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: typeReactions.length,
                  itemBuilder: (context, index) {
                    final reaction = typeReactions[index];
                    return GestureDetector(
                      onTap: () => onReactionSelected(reaction),
                      child: Card(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // TODO: Add flyer preview image here once implemented
                            Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  'Page ${reaction.pageNumber + 1}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Text(
                                reaction.emojiChar,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
