import 'package:flutter/material.dart';
import '../models/emoji_reaction.dart';

class EmojiReactionsBottomSheet extends StatefulWidget {
  final Map<String, List<EmojiReaction>> reactionsByStore;
  final Map<String, String> storeNames;
  final Function(EmojiReaction) onReactionSelected;

  const EmojiReactionsBottomSheet({
    super.key,
    required this.reactionsByStore,
    required this.storeNames,
    required this.onReactionSelected,
  });

  @override
  State<EmojiReactionsBottomSheet> createState() => _EmojiReactionsBottomSheetState();
}

class _EmojiReactionsBottomSheetState extends State<EmojiReactionsBottomSheet> {
  EmojiType? _selectedFilter;

  List<EmojiReaction> _filterReactions(List<EmojiReaction> reactions) {
    if (_selectedFilter == null) return reactions;
    return reactions.where((r) => r.emojiType == _selectedFilter).toList();
  }

  Widget _buildChoiceChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _selectedFilter == null,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...EmojiType.values.map((type) {
            final emoji = EmojiReaction(
              storeId: "0",
              pageNumber: 0,
              xNorm: 0,
              yNorm: 0,
              emojiType: type,
            ).emojiChar;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(emoji),
                selected: _selectedFilter == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? type : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeIds = widget.reactionsByStore.keys.toList();
    if (storeIds.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No reactions yet'),
        ),
      );
    }

    return DefaultTabController(
      length: storeIds.length,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: storeIds.map((storeId) {
                    final storeName = widget.storeNames[storeId] ?? 'Unknown Store';
                    return Tab(text: storeName);
                  }).toList(),
                ),
                _buildChoiceChips(),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: storeIds.map((storeId) {
                final reactions = _filterReactions(widget.reactionsByStore[storeId] ?? []);
                if (reactions.isEmpty) {
                  return const Center(
                    child: Text('No reactions in this category'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: reactions.length,
                  itemBuilder: (context, index) {
                    final reaction = reactions[index];
                    return GestureDetector(
                      onTap: () => widget.onReactionSelected(reaction),
                      child: Card(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // TODO: Add flyer preview image here
                            Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Page ${reaction.pageNumber + 1}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reaction.emojiChar,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ],
                                ),
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
