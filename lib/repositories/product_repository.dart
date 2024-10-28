import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductRepository extends Cubit<List<Product>> {
  static const String _productsUrl = 'https://tammy35334.github.io/test/products.json';

  ProductRepository() : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final response = await http.get(Uri.parse(_productsUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products = data.map((json) => Product.fromJson(json)).toList();
        emit(products);
      }
    } catch (e) {
      emit([]);
    }
  }
}
