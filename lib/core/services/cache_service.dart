import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import '../models/product.dart';
import '../models/flyer.dart';

class CacheService {
  static const String productsBox = 'products';
  static const String flyersBox = 'flyers';
  static const String settingsBox = 'settings';
  static const String imagesBox = 'images';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(productsBox);
    await Hive.openBox(flyersBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(imagesBox);
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

  Future<void> cacheFlyers(List<Flyer> flyers) async {
    final box = Hive.box(flyersBox);
    final flyersMap = {for (var flyer in flyers) flyer.storeId: flyer.toJson()};
    await box.putAll(flyersMap);
  }

  Future<List<Flyer>> getCachedFlyers() async {
    final box = Hive.box(flyersBox);
    return box.values
        .map((json) => Flyer.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> cacheImage(String url, Uint8List bytes) async {
    final box = Hive.box(imagesBox);
    await box.put(url, bytes);
  }

  Future<Uint8List?> getCachedImage(String url) async {
    final box = Hive.box(imagesBox);
    return box.get(url) as Uint8List?;
  }

  Future<void> setPostalCode(String postalCode) async {
    final box = Hive.box(settingsBox);
    await box.put('postal_code', postalCode);
  }

  String? getPostalCode() {
    final box = Hive.box(settingsBox);
    return box.get('postal_code');
  }

  Future<void> setLastFlyerUpdate(DateTime time) async {
    final box = Hive.box(settingsBox);
    await box.put('last_flyer_update', time.toIso8601String());
  }

  DateTime? getLastFlyerUpdate() {
    final box = Hive.box(settingsBox);
    final timeStr = box.get('last_flyer_update');
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }
}
