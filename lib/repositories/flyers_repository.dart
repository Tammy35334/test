// lib/repositories/flyers_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../storage/flyers_storage.dart';
import '../utils/logger.dart';

class FlyersRepository {
  final http.Client httpClient;
  final FlyersStorage storage;

  FlyersRepository({required this.httpClient, required this.storage});

  // Fetch flyers from the API
  Future<List<Store>> fetchFlyers() async {
    // Update the API endpoint as needed
    String url = 'https://tammy35334.github.io/test/flyers.json';

    final response = await httpClient.get(Uri.parse(url));

    if (response.statusCode != 200) {
      logger.severe('Error fetching flyers: ${response.statusCode}');
      throw Exception('Error fetching flyers: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    List<Store> stores = [];

    if (data is List) {
      stores = data.map((json) => Store.fromJson(json)).toList();
    } else if (data is Map<String, dynamic> && data.containsKey('stores')) {
      stores = (data['stores'] as List)
          .map((json) => Store.fromJson(json))
          .toList();
    } else {
      logger.severe('Invalid JSON format for flyers');
      throw Exception('Invalid JSON format for flyers');
    }

    logger.info('Parsed ${stores.length} stores from JSON.');

    // Cache the fetched stores
    await storage.cacheItems(stores);

    logger.info('Cached ${stores.length} stores.');

    return stores;
  }

  // Retrieve cached flyers
  Future<List<Store>> getCachedFlyers() async {
    final cachedStores = await storage.getAllItems();
    logger.info('Retrieved ${cachedStores.length} cached stores.');
    return cachedStores;
  }

  // Search flyers in cached data
  Future<List<Store>> searchFlyers({required String query}) async {
    final allStores = await getCachedFlyers();
    final filteredStores = allStores
        .where((store) =>
            store.storeName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    logger.info('Found ${filteredStores.length} stores matching "$query".');
    return filteredStores;
  }

  Future<void> addFlyer(Store store) async {
    await storage.addItem(store);
    logger.info('Store added: ${store.storeName}');
  }

  Future<void> updateFlyer(Store store) async {
    await storage.updateItem(store);
    logger.info('Store updated: ${store.storeName}');
  }

  Future<void> deleteFlyer(int id) async {
    await storage.deleteItem(id);
    logger.info('Store deleted with id: $id');
  }
}
