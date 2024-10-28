import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../models/flyer.dart';
import '../repositories/flyer_repository.dart';
import '../widgets/optimized_flyer_image.dart';
import '../models/drawing.dart';
import '../services/drawing_manager.dart';
import '../widgets/drawing_painter.dart';


class FlyerDetailScreen extends StatefulWidget {
  final Flyer flyer;

  const FlyerDetailScreen({
    super.key,
    required this.flyer,
  });

  @override
  State<FlyerDetailScreen> createState() => _FlyerDetailScreenState();
}

class _FlyerDetailScreenState extends State<FlyerDetailScreen> {
  late final TransformationController _transformationController;
  late List<Uint8List?> _imageBytesList;
  int _currentIndex = 0;
  bool _isZoomed = false;
  bool _isLoading = true;
  final DrawingManager _drawingManager = DrawingManager();
  List<List<Offset>> _currentStrokes = [];
  bool _isDrawingMode = false;
  
  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformChanged);
    _imageBytesList = List.filled(widget.flyer.flyerImages.length, null);
    _loadImages();
    _drawingManager.init();
    _loadDrawings();
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

  Future<void> _loadDrawings() async {
    final drawings = _drawingManager.getDrawingsForPage(
      widget.flyer.storeId,
      _currentIndex,
    );
    
   setState(() {
  _currentStrokes = drawings
      .map((drawing) => drawing.points
          .map((point) => point.toOffset())
          .toList())
      .toList();
});

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
        // Reset zoom when changing images
        _transformationController.value = Matrix4.identity();
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!_isDrawingMode) return;
    
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    
    setState(() {
      _currentStrokes.add([point]);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawingMode || _currentStrokes.isEmpty) return;
    
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    
    setState(() {
      _currentStrokes.last.add(point);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawingMode || _currentStrokes.isEmpty) return;
    
    final stroke = _currentStrokes.last;
    if (stroke.isEmpty) return;

    // Calculate center of the stroke
    final center = stroke.reduce((a, b) => Offset(a.dx + b.dx, a.dy + b.dy));
    final centerPoint = DrawingPoint.fromOffset(
      Offset(center.dx / stroke.length, center.dy / stroke.length)
    );
    
    // Save drawing
    final drawing = Drawing(
      storeId: widget.flyer.storeId,
      pageIndex: _currentIndex,
      points: stroke.map(DrawingPoint.fromOffset).toList(),
      center: centerPoint,
    );
    
    _drawingManager.saveDrawing(drawing);
  }

  Widget _buildMainImage() {
    if (_isLoading || _imageBytesList[_currentIndex] == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        InteractiveViewer(
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
              CustomPaint(
                painter: DrawingPainter(
                  strokes: _currentStrokes,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        if (_isDrawingMode)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
            ),
          ),
      ],
    );
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
        // Previous Button
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
        // Next Button
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
        // Page indicator
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
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetZoom,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isDrawingMode = !_isDrawingMode;
          });
        },
        child: Icon(_isDrawingMode ? Icons.edit_off : Icons.edit),
      ),
      body: Row(
        children: [
          // Thumbnail Sidebar
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
          // Main Image View
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
