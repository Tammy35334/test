// lib/screens/flyer_detail_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/rendering.dart'; // For RepaintBoundary
import 'dart:ui'; // For ImageByteFormat
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/drawn_line.dart'; // Import the DrawnLine model
import '../utils/logger.dart'; // Logger for logging
import '../blocs/drawing_bloc.dart';
import '../blocs/drawing_event.dart';
import '../blocs/drawing_state.dart';

/// Represents a single line drawn by the user.
class DrawnLineData {
  final List<Offset> points;
  final Paint paint;

  DrawnLineData({required this.points, required this.paint});
}

/// CustomPainter that draws all the lines.
class DrawingPainter extends CustomPainter {
  final List<DrawnLineData> lines;

  DrawingPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      if (line.points.length > 1) {
        for (int i = 0; i < line.points.length - 1; i++) {
          // Draw lines between consecutive points
          canvas.drawLine(line.points[i], line.points[i + 1], line.paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

/// The main page where users can view and draw on flyer images.
class FlyerDetailPage extends StatefulWidget {
  final List<String> flyerImages; // List of image URLs
  final String storeName;
  final String imageId; // Unique identifier for the store

  const FlyerDetailPage({
    super.key,
    required this.flyerImages,
    required this.storeName,
    required this.imageId,
  });

  static const routeName = '/flyerDetail'; // Route name for navigation

  @override
  State<FlyerDetailPage> createState() => _FlyerDetailPageState();
}

class _FlyerDetailPageState extends State<FlyerDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<GlobalKey> _repaintKeys = [];

  // Temporary list to hold points during a drawing gesture
  List<double> _tempPoints = [];

  @override
  void initState() {
    super.initState();
    _initializeRepaintKeys();
    _loadDrawings();
  }

  /// Initializes unique GlobalKeys for each RepaintBoundary.
  void _initializeRepaintKeys() {
    _repaintKeys.clear();
    for (int i = 0; i < widget.flyerImages.length; i++) {
      _repaintKeys.add(GlobalKey());
    }
  }

  /// Loads existing drawings from the DrawingBloc for the initial page.
  void _loadDrawings() {
    if (widget.flyerImages.isNotEmpty) {
      context.read<DrawingBloc>().add(LoadDrawingsEvent(imageId: _getImageKey(_currentPage)));
    }
  }

  /// Generates a unique key for each image based on imageId and index.
  String _getImageKey(int index) {
    return '${widget.imageId}_$index';
  }

  /// Converts a flat list of doubles to a list of Offsets.
  List<Offset> _deserializePoints(List<double> points) {
    List<Offset> offsets = [];
    for (int i = 0; i < points.length; i += 2) {
      offsets.add(Offset(points[i], points[i + 1]));
    }
    return offsets;
  }

  /// Shares the current image along with the drawings.
  Future<void> _shareImageWithDrawings() async {
    try {
      logger.info('Sharing image with drawings for image index $_currentPage.');

      // Capture the image with drawings
      RenderRepaintBoundary? boundary =
          _repaintKeys[_currentPage].currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception("Unable to find render object");
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to capture image with drawings");
      }
      final imageBytes = byteData.buffer.asUint8List();

      // Check if imageBytes is empty
      if (imageBytes.isEmpty) {
        throw Exception("Failed to capture image with drawings");
      }

      // Compress the image to reduce file size
      Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 1080,
        minHeight: 1920,
        quality: 80,
      );

      // Save the compressed image temporarily
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/flyer_${widget.imageId}_$_currentPage.png',
      ).create();
      await file.writeAsBytes(compressedBytes);

      // Share the image using the share_plus package
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this flyer from ${widget.storeName}!',
        subject: 'Flyer from ${widget.storeName}',
      );

      logger.info('Image shared successfully for image index $_currentPage.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flyer shared successfully!')),
        );
      }
    } catch (e) {
      logger.severe('Error sharing image at index $_currentPage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing image: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handles page change to load corresponding drawings.
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    context.read<DrawingBloc>().add(LoadDrawingsEvent(imageId: _getImageKey(index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
        backgroundColor: Colors.white, // Match AppBar style
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: _shareImageWithDrawings,
            tooltip: 'Share',
          ),
        ],
      ),
      body: BlocBuilder<DrawingBloc, DrawingState>(
        builder: (context, state) {
          List<DrawnLineData> currentDrawings = [];
          if (state is DrawingLoaded) {
            currentDrawings = state.drawings.map((line) {
              return DrawnLineData(
                points: _deserializePoints(line.points),
                paint: Paint()
                  ..color = Colors.blueAccent
                  ..strokeWidth = 3.0
                  ..strokeCap = StrokeCap.round
                  ..style = PaintingStyle.stroke,
              );
            }).toList();
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical, // Vertical scrolling
            itemCount: widget.flyerImages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 1.0,
                maxScale: 5.0,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: RepaintBoundary(
                      key: _repaintKeys[index],
                      child: GestureDetector(
                        onPanStart: (details) => _onPanStart(details, index),
                        onPanUpdate: (details) => _onPanUpdate(details, index),
                        onPanEnd: (_) => _onPanEnd(index),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                widget.flyerImages[index],
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.broken_image, size: 50));
                                },
                              ),
                            ),
                            CustomPaint(
                              painter: DrawingPainter(lines: currentDrawings),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Handles the start of a drawing gesture.
  void _onPanStart(DragStartDetails details, int index) {
    RenderBox? renderBox = _repaintKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      _tempPoints = [localPosition.dx, localPosition.dy];
    }
  }

  /// Handles the update of a drawing gesture.
  void _onPanUpdate(DragUpdateDetails details, int index) {
    RenderBox? renderBox = _repaintKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      setState(() {
        _tempPoints.add(localPosition.dx);
        _tempPoints.add(localPosition.dy);
      });
    }
  }

  /// Handles the end of a drawing gesture.
  void _onPanEnd(int index) {
    if (_tempPoints.length > 2) {
      // Create a DrawnLine with the accumulated points
      DrawnLine drawnLine = DrawnLine(points: List.from(_tempPoints));
      context.read<DrawingBloc>().add(AddDrawingEvent(
            imageId: _getImageKey(index),
            drawnLine: drawnLine,
          ));
    }
    _tempPoints = [];
  }
}
