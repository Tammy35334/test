import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/flyer.dart';

class ApiService {
  static const String baseUrl = 'your-cloudflare-url';
  final http.Client _client = http.Client();

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/products.json'),
        headers: {'Accept-Encoding': 'gzip'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Flyer>> fetchFlyers() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/flyers.json'),
        headers: {'Accept-Encoding': 'gzip'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Flyer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load flyers');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
