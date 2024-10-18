// lib/storage/storage_factory.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'flyers_storage.dart';
import 'flyers_storage_interface.dart';
import 'storage_interface.dart';
import '../models/product.dart';
import '../models/store.dart';
import 'hive_storage.dart';

class StorageFactory {
  // Factory method for Product storage
  static Future<StorageInterface> getProductStorage(String boxName) async {
    var box = await Hive.openBox<Product>(boxName);
    return HiveStorage(productsBox: box);
  }

  // Factory method for Store (Flyers) storage
  static Future<FlyersStorageInterface> getFlyersStorage(String boxName) async {
    var box = await Hive.openBox<Store>(boxName);
    return FlyersStorage(flyersBox: box);
  }
}
