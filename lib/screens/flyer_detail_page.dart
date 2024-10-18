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

import '../models/like.dart';
import '../blocs/likes_bloc.dart';
import '../utils/logger.dart';

class FlyerDetailPage extends StatefulWidget {
  final List<String> flyerImages; // List of image URLs
  final String storeName;
  final String imageId; // Unique identifier for the store

  const FlyerDetailPage({
    super.key, // Using super.key
    required this.flyerImages,
    required this.storeName,
    required this.imageId,
  });

  static const routeName = '/flyerDetail'; // Added routeName for named routing

  @override
  _FlyerDetailPageState createState() => _FlyerDetailPageState();
}

class _FlyerDetailPageState extends State<FlyerDetailPage>
    with TickerProviderStateMixin { // Changed from SingleTickerProviderStateMixin
  late PageController _pageController;
  int _currentPage = 0;

  // List of imageIds corresponding to each flyer image
  late List<String> _imageIds;

  // Map to hold TransformationControllers for each image
  final Map<int, TransformationController> _transformationControllers = {};

  // Map to hold GlobalKeys for each RepaintBoundary
  final Map<int, GlobalKey> _repaintBoundaryKeys = {};

  // Map to hold Animated Icons positions for each image
  final Map<int, Offset?> _animatedIconPositions = {};

  // Map to hold AnimationControllers for each image
  final Map<int, AnimationController> _animationControllers = {};

  // Map to hold Animations for each image
  final Map<int, Animation<double>> _animations = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

      _animationControllers[i] = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 300));
      _animations[i] = Tween<double>(begin: 1.0, end: 1.5).animate(
          _animationControllers[i]!)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _animationControllers[i]!.reverse();
          }
        });

      _animatedIconPositions[i] = null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _transformationControllers.values) {
      controller.dispose();
    }
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleLongPress(int index, TapDownDetails details) async {
    final RenderBox? renderBox =
        _repaintBoundaryKeys[index]?.currentContext?.findRenderObject()
            as RenderBox?;
    if (renderBox == null) {
      logger.severe('RenderBox is null for image index $index.');
      return;
    }

    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);
    final Matrix4 matrix = _transformationControllers[index]!.value;

    // Invert the matrix to get the image coordinates
    final Matrix4? inverseMatrix = Matrix4.tryInvert(matrix);
    if (inverseMatrix == null) {
      logger.severe(
          'Failed to invert the transformation matrix for image index $index.');
      return;
    }

    // Use Vector4 from vector_math for proper multiplication
    final vector_math.Vector4 vector =
        vector_math.Vector4(localPosition.dx, localPosition.dy, 0, 1);
    final vector_math.Vector4 transformedVector =
        inverseMatrix.transform(vector);

    final Offset imagePosition =
        Offset(transformedVector.x, transformedVector.y);

    // Ensure the press is within the image bounds
    final Size imageSize = renderBox.size;
    if (imagePosition.dx < 0 ||
        imagePosition.dx > imageSize.width ||
        imagePosition.dy < 0 ||
        imagePosition.dy > imageSize.height) {
      return;
    }

    logger.info(
        'Long pressed at (${imagePosition.dx}, ${imagePosition.dy}) on image index $index.');

    // Show love icon with animation
    setState(() {
      _animatedIconPositions[index] = imagePosition;
    });
    _animationControllers[index]!.forward();

    // Add like to the BLoC
    final like = Like(
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

      RenderRepaintBoundary? boundary =
          _repaintBoundaryKeys[index]?.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(
            'Unable to find RenderRepaintBoundary for image index $index.');
      }

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return _shareImageWithLikes(index);
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception("Failed to capture image");
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final File file =
          await File('${tempDir.path}/flyer_${widget.imageId}_$index.png')
              .create();
      await file.writeAsBytes(pngBytes);

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
      if (mounted) { // Added mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing image: $e')),
        );
      }
    }
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
            setState(() {
              // No action needed here since each image handles its own likes
            });
          }
        },
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical, // Changed to vertical scrolling
          itemCount: widget.flyerImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent, // Allow child gestures first
              onLongPressStart: (details) {
                _handleLongPress(
                    index,
                    TapDownDetails(
                        globalPosition: details.globalPosition));
              },
              child: RepaintBoundary(
                key: _repaintBoundaryKeys[index],
                child: Stack(
                  children: [
                    // Display the image using CachedNetworkImage for caching
                    CachedNetworkImage(
                      imageUrl: widget.flyerImages[index],
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.error, color: Colors.red)),
                      fit: BoxFit.cover, // Makes image take full width and height
                      width: double.infinity, // Full width
                      height: double.infinity, // Full height
                    ),
                    // Overlay existing likes
                    BlocBuilder<LikesBloc, LikesState>(
                      builder: (context, state) {
                        if (state is LikesLoaded) {
                          // Filter likes for the current image
                          final likes = state.likes
                              .where((like) =>
                                  like.imageId ==
                                  _imageIds[index])
                              .toList();
                          return Stack(
                            children: likes.map((like) {
                              return Positioned(
                                left: like.x *
                                    _transformationControllers[index]!
                                        .value
                                        .getMaxScaleOnAxis(),
                                top: like.y *
                                    _transformationControllers[index]!
                                        .value
                                        .getMaxScaleOnAxis(),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque, // Capture gestures fully
                                  onLongPress: () { // Changed from onTap to onLongPress
                                    // Remove like when the love icon is long-pressed
                                    BlocProvider.of<LikesBloc>(context)
                                        .add(RemoveLikeEvent(like: like));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(content: Text('Like removed.')),
                                    );
                                  },
                                  child: Container(
                                    width: 40, // Increased touch area
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    // Animated love icon for new like
                    if (_animatedIconPositions[index] != null)
                      Positioned(
                        left: _animatedIconPositions[index]!.dx *
                            _transformationControllers[index]!
                                .value
                                .getMaxScaleOnAxis(),
                        top: _animatedIconPositions[index]!.dy *
                            _transformationControllers[index]!
                                .value
                                .getMaxScaleOnAxis(),
                        child: ScaleTransition(
                          scale: _animations[index]!, // Assert non-null
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
