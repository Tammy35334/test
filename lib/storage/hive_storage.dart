// lib/storage/hive_storage.dart

import 'package:hive/hive.dart';
import '../models/product.dart';
import 'storage_interface.dart';

class HiveStorage implements StorageInterface {
  final Box<Product> productsBox;

  HiveStorage({required this.productsBox});

  @override
  Future<void> cacheProducts(List<Product> products) async {
    final Map<int, Product> productsMap = { for (var p in products) p.id : p };
    await productsBox.putAll(productsMap);
  }

  @override
  Future<List<Product>> getCachedProducts() async {
    return productsBox.values.toList();
  }
}
