import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/models/flyer.dart';
import '../core/services/cache_service.dart';

class FlyerRepository {
  final CacheService _cacheService;
  final String _flyersUrl = 'https://tammy35334.github.io/test/flyers.json';
  
  FlyerRepository(this._cacheService);

  Future<List<Flyer>> getFlyers() async {
    try {
      // Check if we need to refresh the data
      final lastUpdate = _cacheService.getLastFlyerUpdate();
      final shouldRefresh = lastUpdate == null || 
          DateTime.now().difference(lastUpdate).inHours > 1;

      if (!shouldRefresh) {
        final cachedFlyers = await _cacheService.getCachedFlyers();
        if (cachedFlyers.isNotEmpty) {
          return cachedFlyers;
        }
      }

      // Fetch fresh data
      final response = await http.get(Uri.parse(_flyersUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final flyers = jsonList.map((json) => Flyer.fromJson(json)).toList();
        
        // Cache the flyers
        await _cacheService.cacheFlyers(flyers);
        await _cacheService.setLastFlyerUpdate(DateTime.now());
        
        return flyers;
      }
      
      // If network request fails, try to return cached data
      return await _cacheService.getCachedFlyers();
    } catch (e) {
      // Return cached data in case of any error
      return await _cacheService.getCachedFlyers();
    }
  }

  Future<Uint8List?> getImageBytes(String url) async {
    try {
      // Check cache first
      final cachedImage = await _cacheService.getCachedImage(url);
      if (cachedImage != null) {
        return cachedImage;
      }

      // Fetch from network if not cached
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        // Cache the image
        await _cacheService.cacheImage(url, bytes);
        return bytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
