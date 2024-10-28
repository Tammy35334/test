import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../models/flyer.dart';
import '../models/flyer_image_data.dart';
import '../services/logger_service.dart';

class FlyerRepository extends Cubit<List<Flyer>> {
  static const String _flyersUrl = 'https://tammy35334.github.io/test/flyers.json';
  static const String _flyersBoxName = 'flyers';
  static const String _imagesBoxName = 'flyerImages';
  
  Box<Flyer>? _flyersBox;
  Box<FlyerImageData>? _imagesBox;
  
  // Memory cache for instant access
  final Map<String, Uint8List> _memoryCache = {};

  FlyerRepository() : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _flyersBox = await Hive.openBox<Flyer>(_flyersBoxName);
      _imagesBox = await Hive.openBox<FlyerImageData>(_imagesBoxName);
      
      final cachedFlyers = _flyersBox?.values.toList() ?? [];
      if (cachedFlyers.isNotEmpty) {
        // Preload images into memory cache
        for (final flyer in cachedFlyers) {
          for (final imageUrl in flyer.flyerImages) {
            final imageData = await getImageBytes(imageUrl);
            if (imageData != null) {
              _memoryCache[imageUrl] = imageData;
            }
          }
        }
        emit(cachedFlyers);
      }
      
      await loadFlyers();
    } catch (e) {
      log.warning('Error initializing boxes: $e');
    }
  }

  Future<void> loadFlyers() async {
    try {
      final response = await http.get(Uri.parse(_flyersUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final flyers = data.map((json) => Flyer.fromJson(json)).toList();
        
        // Cache flyers in Hive
        await _flyersBox?.clear();
        for (final flyer in flyers) {
          await _flyersBox?.put(flyer.storeId.toString(), flyer);
          // Download and cache images
          await _cacheImages(flyer.flyerImages);
        }
        
        emit(flyers);
      }
    } catch (e) {
      log.warning('Error loading flyers: $e');
      // If error occurs, use cached data
      final cachedFlyers = _flyersBox?.values.toList() ?? [];
      emit(cachedFlyers);
    }
  }

  Future<void> _cacheImages(List<String> imageUrls) async {
    if (_imagesBox == null) return;

    for (final url in imageUrls) {
      try {
        // Check if image is already cached and not older than 7 days
        final cachedImage = _imagesBox?.get(url);
        if (cachedImage != null && 
            DateTime.now().difference(cachedImage.lastUpdated).inDays < 7) {
          continue;
        }

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final imageData = FlyerImageData(
            url: url,
            imageBytes: response.bodyBytes,
          );
          await _imagesBox?.put(url, imageData);
        }
      } catch (e) {
        log.warning('Error caching image $url: $e');
      }
    }
  }

  Future<Uint8List?> getImageBytes(String url) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(url)) {
        return _memoryCache[url];
      }

      // Check Hive cache
      final cachedImage = _imagesBox?.get(url);
      if (cachedImage != null) {
        _memoryCache[url] = cachedImage.bytes;
        return cachedImage.bytes;
      }

      return null;
    } catch (e) {
      log.warning('Error getting image bytes: $e');
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _flyersBox?.compact();
    await _imagesBox?.compact();
    await _flyersBox?.close();
    await _imagesBox?.close();
    return super.close();
  }
}
