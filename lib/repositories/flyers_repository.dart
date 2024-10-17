// lib/repositories/flyers_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../storage/flyers_storage_interface.dart';

class FlyersRepository {
  final http.Client httpClient;
  final FlyersStorageInterface storage;

  FlyersRepository({required this.httpClient, required this.storage});

  // Fetch all flyers from the API
  Future<List<Store>> fetchAllFlyers() async {
    final url = Uri.parse('https://tammy35334.github.io/test/flyers.json');

    final response = await httpClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error fetching flyers: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    List<Store> stores = [];

    if (data is List) {
      stores = data.map((json) => Store.fromJson(json)).toList();
    } else if (data is Map<String, dynamic> && data.containsKey('stores')) {
      stores = (data['stores'] as List).map((json) => Store.fromJson(json)).toList();
    } else {
      throw Exception('Invalid JSON format');
    }

    print('Parsed ${stores.length} stores from JSON.');

    // Cache the fetched flyers
    await storage.cacheFlyers(stores);

    return stores;
  }

  // Retrieve cached flyers
  Future<List<Store>> getCachedFlyers() async {
    return await storage.getCachedFlyers();
  }
}
