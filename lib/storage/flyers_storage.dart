// lib/storage/flyers_storage.dart

import 'package:hive/hive.dart';
import '../models/store.dart';
import 'flyers_storage_interface.dart';
import '../utils/logger.dart';

class FlyersStorage implements FlyersStorageInterface {
  final Box<Store> flyersBox;

  FlyersStorage({required this.flyersBox});

  @override
  Future<void> cacheFlyers(List<Store> flyers) async {
    final Map<String, Store> flyersMap = { for (var f in flyers) f.storeId : f };
    await flyersBox.putAll(flyersMap);
    logger.info('Cached ${flyers.length} flyers.');
  }

  @override
  Future<List<Store>> getCachedFlyers() async {
    return flyersBox.values.toList();
  }

  @override
  Future<void> addFlyer(Store flyer) async {
    await flyersBox.put(flyer.storeId, flyer);
    logger.info('Added flyer: ${flyer.storeName}');
  }

  @override
  Future<void> updateFlyer(Store flyer) async {
    await flyersBox.put(flyer.storeId, flyer);
    logger.info('Updated flyer: ${flyer.storeName}');
  }

  @override
  Future<void> deleteFlyer(String id) async {
    await flyersBox.delete(id);
    logger.info('Deleted flyer with id: $id');
  }
}
