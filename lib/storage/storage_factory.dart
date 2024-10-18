// lib/storage/storage_factory.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'flyers_storage.dart';
import 'flyers_storage_interface.dart';
import 'storage_interface.dart';
import '../models/product.dart';
import '../models/store.dart';
import 'hive_storage.dart';
import '../models/like.dart';
import 'likes_storage_interface.dart';
import 'hive_likes_storage.dart';

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

static Future<LikesStorageInterface> getLikesStorage(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Like>(boxName);
    }
    final box = Hive.box<Like>(boxName);
    return HiveLikesStorage(box);
  }

}

