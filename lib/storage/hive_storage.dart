// lib/storage/hive_storage.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import 'storage_interface.dart';

class HiveStorage implements StorageInterface {
  final Box<Product> productsBox;

  HiveStorage({required this.productsBox});

  @override
  Future<void> cacheProducts(List<Product> products) async {
    for (var product in products) {
      await productsBox.put(product.id, product);
    }
  }

  @override
  Future<List<Product>> getCachedProducts() async {
    return productsBox.values.toList();
  }
}
