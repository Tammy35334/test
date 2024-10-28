import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class CacheService {
  static const String productsBox = 'products';
  static const String flyersBox = 'flyers';
  static const String settingsBox = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(productsBox);
    await Hive.openBox(flyersBox);
    await Hive.openBox(settingsBox);
  }

  Future<void> cacheProducts(List<Product> products) async {
    final box = Hive.box(productsBox);
    final productsMap = {for (var product in products) product.id: product.toJson()};
    await box.putAll(productsMap);
  }

  Future<List<Product>> getCachedProducts() async {
    final box = Hive.box(productsBox);
    return box.values
        .map((json) => Product.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> setPostalCode(String postalCode) async {
    final box = Hive.box(settingsBox);
    await box.put('postal_code', postalCode);
  }

  String? getPostalCode() {
    final box = Hive.box(settingsBox);
    return box.get('postal_code');
  }
}
