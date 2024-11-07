import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../models/flyer.dart';
import '../repositories/flyer_repository.dart';
import '../widgets/optimized_flyer_image.dart';
import '../models/emoji_reaction.dart';
import '../services/emoji_reaction_manager.dart';
import '../widgets/emoji_reactions_bottom_sheet.dart';

class FlyerDetailScreen extends StatefulWidget {
  final Flyer flyer;
  final int initialPage;
  final VoidCallback? onShowList;

  const FlyerDetailScreen({
    super.key,
    required this.flyer,
    this.initialPage = 0,
    this.onShowList,
  });

  @override
  State<FlyerDetailScreen> createState() => _FlyerDetailScreenState();
}

class _FlyerDetailScreenState extends State<FlyerDetailScreen> {
  late final TransformationController _transformationController;
  late List<Uint8List?> _imageBytesList;
  late int _currentIndex;
  bool _isZoomed = false;
  bool _isLoading = true;
  late final EmojiReactionManager _emojiManager;
  Map<String, List<EmojiReaction>>? _reactionsByStore;
  Map<String, String> _storeNames = {};
  EmojiType _selectedEmoji = EmojiType.heart; // Default emoji
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformChanged);
    _imageBytesList = List.filled(widget.flyer.flyerImages.length, null);
    _loadImages();
    _emojiManager = context.read<EmojiReactionManager>();
    _loadReactions();
  }

  Future<void> _loadReactions() async {
    await _emojiManager.init();
    setState(() {
      _reactionsByStore = {
        widget.flyer.storeId.toString(): _emojiManager.getReactionsForStore(widget.flyer.storeId.toString())
      };
      _storeNames = {
        widget.flyer.storeId.toString(): widget.flyer.storeName
      };
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    final repository = context.read<FlyerRepository>();
    final loadedImages = await Future.wait(
      widget.flyer.flyerImages.map((url) => repository.getImageBytes(url))
    );
    
    if (mounted) {
      setState(() {
        _imageBytesList = loadedImages;
        _isLoading = false;
      });
    }
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (_isZoomed != (scale > 1.0)) {
      setState(() {
        _isZoomed = scale > 1.0;
      });
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _navigateToImage(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _transformationController.value = Matrix4.identity();
      });
    }
  }

  void _showEmojiSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Emoji'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: EmojiType.values.map((type) {
            final emoji = EmojiReaction(
              storeId: "0",
              pageNumber: 0,
              xNorm: 0,
              yNorm: 0,
              emojiType: type,
            ).emojiChar;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedEmoji = type;
                });
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedEmoji == type ? Colors.blue.withOpacity(0.2) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onLongPress(LongPressStartDetails details) {
    if (_isZoomed) return;

    final box = context.findRenderObject() as RenderBox;
    final position = box.globalToLocal(details.globalPosition);
    final size = box.size;
    
    final reaction = EmojiReaction.fromPixelPosition(
      storeId: widget.flyer.storeId,
      pageNumber: _currentIndex,
      position: position,
      pageSize: size,
      emojiType: _selectedEmoji,
    );

    _emojiManager.saveReaction(reaction);
    _loadReactions(); // Refresh reactions
  }

  void _showReactionsBottomSheet() {
    if (_reactionsByStore == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => EmojiReactionsBottomSheet(
          reactionsByStore: _reactionsByStore!,
          storeNames: _storeNames,
          onReactionSelected: (reaction) {
            Navigator.pop(context);
            _navigateToImage(reaction.pageNumber);
          },
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    if (_isLoading || _imageBytesList[_currentIndex] == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onLongPressStart: _onLongPress,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        child: Stack(
          children: [
            OptimizedFlyerImage(
              key: ValueKey('image_$_currentIndex'),
              imageBytes: _imageBytesList[_currentIndex]!,
              fit: BoxFit.contain,
            ),
            if (!_isZoomed) ..._buildEmojiOverlays(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmojiOverlays() {
    final reactions = _emojiManager.getReactionsForPage(
      widget.flyer.storeId.toString(),
      _currentIndex,
    );

    return reactions.map((reaction) {
      final position = reaction.getPixelPosition(
        MediaQuery.of(context).size,
      );

      return Positioned(
        left: position.dx - 12,
        top: position.dy - 12,
        child: Text(
          reaction.emojiChar,
          style: const TextStyle(fontSize: 24),
        ),
      );
    }).toList();
  }

  Widget _buildThumbnail(int index) {
    if (_imageBytesList[index] == null) {
      return const SizedBox(height: 100);
    }

    return GestureDetector(
      onTap: () => _navigateToImage(index),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: _currentIndex == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: RepaintBoundary(
            child: OptimizedFlyerImage(
              imageBytes: _imageBytesList[index]!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationUI() {
    return Stack(
      children: [
        if (_currentIndex > 0)
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavigationButton(
                Icons.chevron_left,
                () => _navigateToImage(_currentIndex - 1),
              ),
            ),
          ),
        if (_currentIndex < widget.flyer.flyerImages.length - 1)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavigationButton(
                Icons.chevron_right,
                () => _navigateToImage(_currentIndex + 1),
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.flyer.flyerImages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flyer.storeName),
        leading: widget.onShowList != null ? IconButton(
          icon: const Icon(Icons.list),
          onPressed: widget.onShowList,
        ) : null,
        actions: [
          IconButton(
            icon: Text(
              EmojiReaction(
                storeId: "0",
                pageNumber: 0,
                xNorm: 0,
                yNorm: 0,
                emojiType: _selectedEmoji,
              ).emojiChar,
              style: const TextStyle(fontSize: 24),
            ),
            onPressed: _showEmojiSelector,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetZoom,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReactionsBottomSheet,
        child: const Icon(Icons.pets), // Cat paw icon
      ),
      body: Row(
        children: [
          SizedBox(
            width: 100,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.flyer.flyerImages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildThumbnail(index),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Stack(
              children: [
                _buildMainImage(),
                if (!_isZoomed) _buildNavigationUI(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
