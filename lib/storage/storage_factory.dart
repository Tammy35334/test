// lib/storage/storage_factory.dart

// ignore: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import 'hive_storage.dart';
import 'storage_interface.dart';

class StorageFactory {
  static Future<StorageInterface> getStorage() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductAdapter());
    var box = await Hive.openBox<Product>('productsBox');
    return HiveStorage(productsBox: box);
  }
}
