// lib/storage/storage_interface.dart

import '../models/product.dart';

abstract class StorageInterface {
  Future<void> cacheProducts(List<Product> products);
  Future<List<Product>> getCachedProducts();
}
