import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/flyer.dart';
import '../models/emoji_reaction.dart';
import '../services/emoji_reaction_manager.dart';
import '../services/selected_emoji_notifier.dart';
import '../widgets/emoji_reactions_bottom_sheet.dart';
import 'flyer_detail_screen.dart';

class FlyersPage extends StatefulWidget {
  const FlyersPage({super.key});

  @override
  State<FlyersPage> createState() => _FlyersPageState();
}

class _FlyersPageState extends State<FlyersPage> {
  late final SelectedEmojiNotifier _selectedEmojiNotifier;
  late final EmojiReactionManager _emojiManager;
  Map<String, List<EmojiReaction>>? _reactionsByStore;
  Map<String, String> _storeNames = {};

  @override
  void initState() {
    super.initState();
    _selectedEmojiNotifier = SelectedEmojiNotifier();
    _emojiManager = context.read<EmojiReactionManager>();
    _loadReactions();
  }

  Future<void> _loadReactions() async {
    await _emojiManager.init();
    setState(() {
      _reactionsByStore = _emojiManager.getReactionsByStore();
    });
  }

  @override
  void dispose() {
    _selectedEmojiNotifier.dispose();
    super.dispose();
  }

  void _showEmojiSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select Default Emoji',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: EmojiType.values.map((type) {
                final emoji = EmojiReaction(
                  storeId: "0",
                  pageNumber: 0,
                  xNorm: 0,
                  yNorm: 0,
                  emojiType: type,
                ).emojiChar;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      _selectedEmojiNotifier.value = type;
                      Navigator.pop(context);
                    },
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showReactionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => EmojiReactionsBottomSheet(
          reactionsByStore: _reactionsByStore ?? {},
          storeNames: _storeNames,
          onReactionSelected: (reaction) {
            Navigator.pop(context);
            // TODO: Navigate to the specific flyer and page
          },
        ),
      ),
    );
  }

  void _navigateToFlyerDetail(Flyer flyer) {
    _storeNames[flyer.storeId] = flyer.storeName;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedEmojiProvider(
          child: FlyerDetailScreen(flyer: flyer),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flyers'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'select_emoji',
            onPressed: _showEmojiSelector,
            child: ValueListenableBuilder<EmojiType>(
              valueListenable: _selectedEmojiNotifier,
              builder: (context, selectedType, _) {
                final emoji = EmojiReaction(
                  storeId: "0",
                  pageNumber: 0,
                  xNorm: 0,
                  yNorm: 0,
                  emojiType: selectedType,
                ).emojiChar;
                return Text(emoji, style: const TextStyle(fontSize: 24));
              },
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'view_reactions',
            onPressed: _showReactionsBottomSheet,
            child: const Icon(Icons.pets),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 0, // TODO: Replace with actual flyer count
        itemBuilder: (context, index) {
          return const SizedBox(); // TODO: Replace with actual flyer item
        },
      ),
    );
  }
}
