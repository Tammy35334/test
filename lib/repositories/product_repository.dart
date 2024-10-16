// lib/repositories/product_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../storage/storage_interface.dart';

class ProductRepository {
  final http.Client httpClient;
  final StorageInterface storage;

  ProductRepository({required this.httpClient, required this.storage});

  // Fetch products from the API
  Future<List<Product>> fetchProducts({
    required int page,
    required int limit,
    String? query,
  }) async {
    // Update the API endpoint as needed
    String url =
        'https://tammy35334.github.io/test/products.json?page=$page&limit=$limit';

    if (query != null && query.isNotEmpty) {
      // If your API supports search queries, append them here
      url += '&search=${Uri.encodeQueryComponent(query)}';
    }

    final response = await httpClient.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Error fetching products: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    List<Product> products = [];

    if (data is List) {
      products = data.map((json) => Product.fromJson(json)).toList();
    } else if (data is Map<String, dynamic> && data.containsKey('products')) {
      products = (data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      throw Exception('Invalid JSON format');
    }

    // Cache the fetched products
    await storage.cacheProducts(products);

    return products;
  }

  // Retrieve cached products
  Future<List<Product>> getCachedProducts() async {
    return await storage.getCachedProducts();
  }
}
