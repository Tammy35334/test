// lib/repositories/product_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../storage/storage_interface.dart';
import '../utils/logger.dart';

class ProductRepository {
  final http.Client httpClient;
  final StorageInterface<Product> storage;

  ProductRepository({required this.httpClient, required this.storage});

  // Fetch products from the API
  Future<List<Product>> fetchProducts() async {
    // Update the API endpoint as needed
    String url = 'https://tammy35334.github.io/test/products.json';

    final response = await httpClient.get(Uri.parse(url));

    if (response.statusCode != 200) {
      logger.severe('Error fetching products: ${response.statusCode}');
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
      logger.severe('Invalid JSON format');
      throw Exception('Invalid JSON format');
    }

    logger.info('Parsed ${products.length} products from JSON.');

    // Cache the fetched products
    await storage.cacheItems(products);

    logger.info('Cached ${products.length} products.');

    return products;
  }

  // Retrieve cached products
  Future<List<Product>> getCachedProducts() async {
    final cachedProducts = await storage.getAllItems();
    logger.info('Retrieved ${cachedProducts.length} cached products.');
    return cachedProducts;
  }

  // Search products in cached data
  Future<List<Product>> searchProducts({required String query}) async {
    final allProducts = await getCachedProducts();
    final filteredProducts = allProducts
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    logger.info('Found ${filteredProducts.length} products matching "$query".');
    return filteredProducts;
  }

  Future<void> addProduct(Product product) async {
    await storage.addItem(product);
    logger.info('Product added: ${product.name}');
  }

  Future<void> updateProduct(Product product) async {
    await storage.updateItem(product);
    logger.info('Product updated: ${product.name}');
  }

  Future<void> deleteProduct(int id) async {
    await storage.deleteItem(id);
    logger.info('Product deleted with id: $id');
  }
}
