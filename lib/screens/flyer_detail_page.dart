// lib/screens/flyer_detail_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/rendering.dart'; // For RepaintBoundary
import 'dart:ui'; // For ImageByteFormat
import 'package:hive/hive.dart';
import '../models/drawn_line.dart'; // Import the DrawnLine model
import '../utils/logger.dart'; // Logger for logging

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
          // No need to check for nulls since points are non-nullable
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

  late final List<GlobalKey> _repaintKeys;
  late final List<List<DrawnLineData>> _drawnLines;
  late final List<List<Offset>> _currentPointsList;

  @override
  void initState() {
    super.initState();
    _initializeRepaintKeys();
    _initializeDrawnLines();
    _initializeCurrentPointsList();
    _loadDrawings();
  }

  /// Initializes unique GlobalKeys for each RepaintBoundary.
  void _initializeRepaintKeys() {
    _repaintKeys = List.generate(widget.flyerImages.length, (_) => GlobalKey());
  }

  /// Initializes empty lists to store drawn lines for each image.
  void _initializeDrawnLines() {
    _drawnLines = List.generate(widget.flyerImages.length, (_) => <DrawnLineData>[]);
  }

  /// Initializes empty lists to store current points being drawn for each image.
  void _initializeCurrentPointsList() {
    _currentPointsList = List.generate(widget.flyerImages.length, (_) => <Offset>[]);
  }

  /// Loads existing drawings from Hive.
  Future<void> _loadDrawings() async {
    final flyerDrawingsBox = Hive.box<List<DrawnLine>>('drawingsBox');
    for (int i = 0; i < widget.flyerImages.length; i++) {
      List<DrawnLine>? storedLines = flyerDrawingsBox.get('${widget.imageId}_$i');
      if (storedLines != null) {
        setState(() {
          _drawnLines[i] = storedLines
              .map((line) => DrawnLineData(
                    points: _deserializePoints(line.points),
                    paint: Paint()
                      ..color = Colors.blueAccent
                      ..strokeWidth = 3.0
                      ..strokeCap = StrokeCap.round
                      ..style = PaintingStyle.stroke,
                  ))
              .toList();
        });
      }
    }
  }

  /// Converts a flat list of doubles to a list of Offsets.
  List<Offset> _deserializePoints(List<double> points) {
    List<Offset> offsets = [];
    for (int i = 0; i < points.length; i += 2) {
      offsets.add(Offset(points[i], points[i + 1]));
    }
    return offsets;
  }

  /// Handles the start of a drawing gesture.
  void _onPanStart(DragStartDetails details, int index) {
    RenderBox? renderBox = _repaintKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      setState(() {
        _currentPointsList[index].add(localPosition);
      });
    }
  }

  /// Handles the update of a drawing gesture.
  void _onPanUpdate(DragUpdateDetails details, int index) {
    RenderBox? renderBox = _repaintKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      setState(() {
        _currentPointsList[index].add(localPosition);
      });
    }
  }

  /// Handles the end of a drawing gesture.
  void _onPanEnd(int index) {
    if (_currentPointsList[index].isNotEmpty) {
      final paint = Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final drawnLine = DrawnLineData(points: List.from(_currentPointsList[index]), paint: paint);
      setState(() {
        _drawnLines[index].add(drawnLine);
        _currentPointsList[index].clear();
      });

      // Save the updated drawings to Hive
      _saveDrawings(index);
    }
  }

  /// Saves the drawn lines for a specific image to Hive.
  void _saveDrawings(int index) {
    final flyerDrawingsBox = Hive.box<List<DrawnLine>>('drawingsBox');
    List<DrawnLine> linesToSave = _drawnLines[index].map((line) {
      return DrawnLine(
        points: line.points.expand((offset) => [offset.dx, offset.dy]).toList(),
      );
    }).toList();

    flyerDrawingsBox.put('${widget.imageId}_$index', linesToSave);
    logger.info('Drawings saved for image index $index.');
  }

  /// Shares the current image along with the drawings.
  Future<void> _shareImageWithDrawings(int index) async {
    try {
      logger.info('Sharing image with drawings for image index $index.');

      // Capture the image with drawings
      RenderRepaintBoundary? boundary =
          _repaintKeys[index].currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
        '${tempDir.path}/flyer_${widget.imageId}_$index.png',
      ).create();
      await file.writeAsBytes(compressedBytes);

      // Share the image using the share_plus package
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this flyer from ${widget.storeName}!',
        subject: 'Flyer from ${widget.storeName}',
      );

      logger.info('Image shared successfully for image index $index.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flyer shared successfully!')),
        );
      }
    } catch (e) {
      logger.severe('Error sharing image at index $index: $e');
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
            onPressed: () {
              // Share the current image
              _shareImageWithDrawings(_currentPage);
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical, // Vertical scrolling
        itemCount: widget.flyerImages.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          // Implement logic to detect if the image URL has changed and clear drawings
          // For example:
          // String newImageUrl = getNewImageUrlSomehow();
          // _clearDrawingsIfImageChanged(index, newImageUrl);
        },
        itemBuilder: (context, index) {
          return RepaintBoundary(
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
                    ),
                  ),
                  CustomPaint(
                    painter: DrawingPainter(lines: _drawnLines[index]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
