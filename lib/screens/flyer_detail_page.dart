// lib/screens/flyer_detail_page.dart

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary
import 'package:vector_math/vector_math_64.dart' as vector_math; // Imported with alias
import 'package:cached_network_image/cached_network_image.dart'; // For image caching
import 'package:flutter_image_compress/flutter_image_compress.dart'; // For image compression

import '../models/like.dart';
import '../blocs/likes_bloc.dart';
import '../utils/logger.dart';
import 'like_icon.dart'; // Import the LikeIcon widget

class FlyerDetailPage extends StatefulWidget {
  final List<String> flyerImages; // List of image URLs
  final String storeName;
  final String imageId; // Unique identifier for the store

  const FlyerDetailPage({
    super.key, // Converted to super parameter
    required this.flyerImages,
    required this.storeName,
    required this.imageId,
  });

  static const routeName = '/flyerDetail'; // Added routeName for named routing

  @override
  State<FlyerDetailPage> createState() => _FlyerDetailPageState();
}

class _FlyerDetailPageState extends State<FlyerDetailPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<String> _imageIds;

  final Map<int, TransformationController> _transformationControllers = {};
  final Map<int, GlobalKey> _repaintBoundaryKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeImageIds();
    _initializeControllers();
  }

  void _initializeImageIds() {
    _imageIds = List.generate(
        widget.flyerImages.length, (index) => '${widget.imageId}_$index');
  }

  void _initializeControllers() {
    for (int i = 0; i < widget.flyerImages.length; i++) {
      _transformationControllers[i] = TransformationController();
      _repaintBoundaryKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _transformationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleLongPress(int index, TapDownDetails details) async {
    final repaintKey = _repaintBoundaryKeys[index];
    if (repaintKey == null || repaintKey.currentContext == null) {
      logger.severe('RepaintBoundary key or context is null for image index $index.');
      return;
    }

    final renderObject = repaintKey.currentContext!.findRenderObject();
    if (renderObject is! RenderBox) {
      logger.severe('RenderObject is not a RenderBox for image index $index.');
      return;
    }

    final RenderBox renderBox = renderObject;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    final Matrix4 matrix = _transformationControllers[index]!.value;
    final Matrix4? inverseMatrix = Matrix4.tryInvert(matrix);
    if (inverseMatrix == null) {
      logger.severe('Failed to invert transformation matrix for image index $index.');
      return;
    }

    final vector_math.Vector4 vector = vector_math.Vector4(localPosition.dx, localPosition.dy, 0, 1);
    final vector_math.Vector4 transformedVector = inverseMatrix.transform(vector);

    final Offset imagePosition = Offset(transformedVector.x, transformedVector.y);

    // Ensure the press is within the image bounds
    final Size imageSize = renderBox.size;
    if (imagePosition.dx < 0 ||
        imagePosition.dx > imageSize.width ||
        imagePosition.dy < 0 ||
        imagePosition.dy > imageSize.height) {
      return;
    }

    logger.info('Long pressed at (${imagePosition.dx}, ${imagePosition.dy}) on image index $index.');

    // Add like to the BLoC using the factory constructor
    final like = Like.create(
      storeName: widget.storeName,
      imageId: _imageIds[index],
      x: imagePosition.dx,
      y: imagePosition.dy,
    );
    BlocProvider.of<LikesBloc>(context).add(AddLikeEvent(like: like));
  }

  Future<void> _shareImageWithLikes(int index) async {
    try {
      logger.info('Sharing image with likes for image index $index.');

      final repaintKey = _repaintBoundaryKeys[index];
      if (repaintKey == null || repaintKey.currentContext == null) {
        throw Exception('RepaintBoundary key or context is null for image index $index.');
      }

      final renderObject = repaintKey.currentContext!.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('RenderObject is not a RenderRepaintBoundary for image index $index.');
      }

      if (renderObject.debugNeedsPaint) {
        await _waitForBoundaryToPaint(renderObject);
      }

      ui.Image image = await renderObject.toImage(pixelRatio: 3.0);
      ByteData? byteData;
      try {
        byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      } catch (e) {
        logger.severe('Error converting image to byte data: $e');
        rethrow; // Preserves the original stack trace
      }

      if (byteData == null) throw Exception("Failed to capture image"); // Ensure byteData is not null

      Uint8List pngBytes = byteData.buffer.asUint8List(); // Safe to access buffer now

      // Compress the image
      Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
        pngBytes,
        minWidth: 1080,
        minHeight: 1920,
        quality: 80,
      );

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/flyer_${widget.imageId}_$index.png',
      ).create();
      await file.writeAsBytes(compressedBytes);

      // Share the image using shareXFiles
      final ShareResult result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this flyer from ${widget.storeName}!',
        subject: 'Flyer from ${widget.storeName}',
      );

      if (result.status == ShareResultStatus.success) {
        logger.info('Image shared successfully for image index $index.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Flyer shared successfully!')),
          );
        }
      } else if (result.status == ShareResultStatus.dismissed) {
        logger.info('Share dialog dismissed for image index $index.');
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

  Future<void> _waitForBoundaryToPaint(RenderRepaintBoundary boundary, [int retries = 0]) async {
    if (retries >= 5) {
      throw Exception('Boundary did not stabilize after 5 retries.');
    }
    await Future.delayed(const Duration(milliseconds: 20));
    if (boundary.debugNeedsPaint) {
      await _waitForBoundaryToPaint(boundary, retries + 1);
    }
  }

  Widget _buildFlyerImage(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // Allow child gestures first
      onLongPressStart: (details) {
        _handleLongPress(
          index,
          TapDownDetails(
            globalPosition: details.globalPosition,
          ),
        );
      },
      child: RepaintBoundary(
        key: _repaintBoundaryKeys[index],
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationControllers[index],
              child: CachedNetworkImage(
                imageUrl: widget.flyerImages[index],
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Overlay existing likes
            BlocBuilder<LikesBloc, LikesState>(
              builder: (context, state) {
                if (state is LikesLoaded) {
                  // Filter likes for the current image
                  final likes = state.likes
                      .where((like) => like.imageId == _imageIds[index])
                      .toList();
                  return Stack(
                    children: likes.map((like) {
                      return LikeIcon(
                        key: ValueKey(like.id), // Ensure unique key per like
                        like: like,
                        transformationController: _transformationControllers[index]!,
                        onRemove: () {
                          BlocProvider.of<LikesBloc>(context).add(RemoveLikeEvent(like: like));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Like removed.')),
                          );
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
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
              _shareImageWithLikes(_currentPage);
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: BlocListener<LikesBloc, LikesState>(
        listener: (context, state) {
          if (state is LikesLoaded) {
            // Removed unnecessary setState to avoid rebuilds
          }
        },
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical, // Vertical scrolling
          itemCount: widget.flyerImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return _buildFlyerImage(index);
          },
        ),
      ),
    );
  }
}
