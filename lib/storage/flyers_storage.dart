// lib/storage/flyers_storage.dart

import 'package:hive/hive.dart';
import '../models/store.dart';
import '../storage/storage_interface.dart';
import '../utils/logger.dart';

class FlyersStorage implements StorageInterface<Store> {
  final Box<Store> flyersBox;

  FlyersStorage({required this.flyersBox});

  @override
  Future<void> addItem(Store item) async {
    await flyersBox.put(item.storeId, item); // Use storeId as key
    logger.info('Store added with ID: ${item.storeId}');
  }

  @override
  Future<void> updateItem(Store item) async {
    await flyersBox.put(item.storeId, item); // Use storeId as key
    logger.info('Store updated with ID: ${item.storeId}');
  }

  @override
  Future<void> deleteItem(int id) async {
    await flyersBox.delete(id);
    logger.info('Store deleted with ID: $id');
  }

  @override
  Future<List<Store>> getAllItems() async {
    return flyersBox.values.toList();
  }

  @override
  Future<void> cacheItems(List<Store> items) async {
    final Map<dynamic, Store> itemsMap = {};
    for (var item in items) {
      itemsMap[item.storeId] = item; // Use storeId as key
    }
    await flyersBox.putAll(itemsMap);
    logger.info('Cached ${items.length} stores.');
  }
}
