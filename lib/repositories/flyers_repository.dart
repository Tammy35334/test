// lib/repositories/flyers_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../models/metadata_storage.dart';
import '../storage/flyers_storage_interface.dart';
import '../utils/logger.dart';
import 'package:hive/hive.dart';

class FlyersRepository {
  final http.Client httpClient;
  final FlyersStorageInterface storage;
  final Box<Metadata> metadataBox;

  FlyersRepository({
    required this.httpClient,
    required this.storage,
    required this.metadataBox,
  });

  /// Fetches flyers with a data freshness check.
  Future<List<Store>> fetchFlyers({required int page, required int limit}) async {
    final String metadataKey = 'flyers_last_fetch';
    final Metadata? metadata = metadataBox.get(metadataKey);

    final bool shouldFetch = metadata == null ||
        DateTime.now().difference(metadata.timestamp).inDays >= 7;

    if (shouldFetch) {
      logger.info('Fetching fresh flyers data from server.');
      try {
        final fetchedFlyers = await _fetchFlyersFromServer(page: page, limit: limit);
        await storage.cacheFlyers(fetchedFlyers);
        metadataBox.put(metadataKey, Metadata(key: metadataKey, timestamp: DateTime.now()));
        return fetchedFlyers;
      } catch (e) {
        logger.severe('Error fetching flyers: $e');
        throw Exception('Error fetching flyers: $e');
      }
    } else {
      logger.info('Using cached flyers data.');
      try {
        return await storage.getCachedFlyers();
      } catch (e) {
        logger.severe('Error retrieving cached flyers: $e');
        throw Exception('Error retrieving cached flyers: $e');
      }
    }
  }

  /// Actual server fetching logic.
  Future<List<Store>> _fetchFlyersFromServer({required int page, required int limit}) async {
    final url = Uri.parse('https://tammy35334.github.io/test/flyers.json?page=$page&limit=$limit');
    final response = await httpClient.get(url);

    if (response.statusCode != 200) {
      logger.severe('Error fetching flyers: ${response.statusCode}');
      throw Exception('Error fetching flyers: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    List<Store> stores = [];

    if (data is List) {
      stores = data.map((json) => Store.fromJson(json)).toList();
    } else if (data is Map<String, dynamic> && data.containsKey('stores')) {
      stores = (data['stores'] as List).map((json) => Store.fromJson(json)).toList();
    } else {
      logger.severe('Invalid JSON format');
      throw Exception('Invalid JSON format');
    }

    logger.info('Parsed ${stores.length} stores from JSON.');

    return stores;
  }

  /// Retrieves cached flyers from Hive storage.
  Future<List<Store>> getCachedFlyers() async {
    try {
      final cachedFlyers = await storage.getCachedFlyers();
      logger.info('Retrieved ${cachedFlyers.length} cached flyers.');
      return cachedFlyers;
    } catch (e) {
      logger.severe('Error retrieving cached flyers: $e');
      throw Exception('Error retrieving cached flyers: $e');
    }
  }

  /// Adds a new flyer to Hive storage.
  Future<void> addFlyer(Store flyer) async {
    try {
      await storage.addFlyer(flyer);
      logger.info('Flyer added: ${flyer.storeName}');
    } catch (e) {
      logger.severe('Error adding flyer: $e');
      throw Exception('Error adding flyer: $e');
    }
  }

  /// Updates an existing flyer in Hive storage.
  Future<void> updateFlyer(Store flyer) async {
    try {
      await storage.updateFlyer(flyer);
      logger.info('Flyer updated: ${flyer.storeName}');
    } catch (e) {
      logger.severe('Error updating flyer: $e');
      throw Exception('Error updating flyer: $e');
    }
  }

  /// Deletes a flyer from Hive storage.
  Future<void> deleteFlyer(int id) async {
    try {
      await storage.deleteFlyer(id);
      logger.info('Flyer deleted with id: $id');
    } catch (e) {
      logger.severe('Error deleting flyer: $e');
      throw Exception('Error deleting flyer: $e');
    }
  }
}
