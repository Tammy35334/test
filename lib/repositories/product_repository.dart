// lib/repositories/product_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductRepository {
  final http.Client httpClient;

  ProductRepository({required this.httpClient});

  // Fetch products from the hosted JSON file with pagination
  Future<List<Product>> fetchProducts({required int page, required int limit}) async {
    final response = await httpClient.get(
      Uri.parse('https://tammy35334.github.io/test/products.json'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final data = jsonDecode(response.body) as List;
    final start = (page - 1) * limit;
    // Removed the unused 'end' variable
    final paginatedData = data.skip(start).take(limit).toList();

    return paginatedData.map((json) => Product.fromJson(json)).toList();
  }
}
