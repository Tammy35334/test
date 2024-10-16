import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductRepository {
  final http.Client httpClient;

  ProductRepository({required this.httpClient});

  // Fetch products from the API with pagination
  Future<List<Product>> fetchProducts({required int page, required int limit}) async {
    final response = await httpClient.get(
      Uri.parse('https://api.example.com/products?page=$page&limit=$limit'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
