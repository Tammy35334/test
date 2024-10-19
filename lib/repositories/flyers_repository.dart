// lib/repositories/flyers_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../storage/flyers_storage_interface.dart';
import '../utils/logger.dart'; // Import the logger

class FlyersRepository {
  final http.Client httpClient;
  final FlyersStorageInterface storage;

  FlyersRepository({required this.httpClient, required this.storage});

  // Fetch all flyers from the API
  Future<List<Store>> fetchAllFlyers() async {
    final url = Uri.parse('https://tammy35334.github.io/test/flyers.json');

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

    // Cache the fetched flyers
    await storage.cacheFlyers(stores);
    logger.info('Cached ${stores.length} flyers.');

    return stores;
  }

  // Retrieve cached flyers
  Future<List<Store>> getCachedFlyers() async {
    final cachedFlyers = await storage.getCachedFlyers();
    logger.info('Retrieved ${cachedFlyers.length} cached flyers.');
    return cachedFlyers;
  }

  Future<void> addFlyer(Store flyer) async {
    await storage.addFlyer(flyer);
    logger.info('Flyer added: ${flyer.storeName}');
  }

  Future<void> updateFlyer(Store flyer) async {
    await storage.updateFlyer(flyer);
    logger.info('Flyer updated: ${flyer.storeName}');
  }

  Future<void> deleteFlyer(String id) async {
    await storage.deleteFlyer(id);
    logger.info('Flyer deleted with id: $id');
  }
}
