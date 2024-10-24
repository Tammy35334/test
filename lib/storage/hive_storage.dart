// lib/storage/hive_storage.dart

import 'package:hive/hive.dart';
import '../storage/storage_interface.dart';
import '../utils/logger.dart';
import '../models/product.dart';
import '../models/store.dart';

class HiveStorage<T extends HiveObject> implements StorageInterface<T> {
  final Box<T> box;

  HiveStorage({required this.box});

  @override
  Future<void> addItem(T item) async {
    if (item is Product) {
      await box.put(item.id, item); // Use item.id as the key
      logger.info('Product added with ID: ${item.id}');
    } else if (item is Store) {
      await box.put(item.storeId, item); // Use item.storeId as the key
      logger.info('Store added with ID: ${item.storeId}');
    } else {
      await box.add(item); // Fallback to auto-incremented key
      logger.info('Item added with auto-generated ID.');
    }
  }

  @override
  Future<void> updateItem(T item) async {
    if (item is Product) {
      await box.put(item.id, item); // Use item.id as the key
      logger.info('Product updated with ID: ${item.id}');
    } else if (item is Store) {
      await box.put(item.storeId, item); // Use item.storeId as the key
      logger.info('Store updated with ID: ${item.storeId}');
    } else {
      await item.save();
      logger.info('Item updated with ID: ${item.key}');
    }
  }

  @override
  Future<void> deleteItem(int id) async {
    await box.delete(id);
    logger.info('Item deleted with ID: $id');
  }

  @override
  Future<List<T>> getAllItems() async {
    return box.values.toList();
  }

  @override
  Future<void> cacheItems(List<T> items) async {
    final Map<dynamic, T> itemsMap = {};
    for (var item in items) {
      if (item is Product) {
        itemsMap[item.id] = item; // Use item.id as the key
      } else if (item is Store) {
        itemsMap[item.storeId] = item; // Use item.storeId as the key
      } else {
        // Fallback to auto-incremented key if possible
        itemsMap[item.key] = item;
      }
    }
    await box.putAll(itemsMap);
    logger.info('Cached ${items.length} items.');
  }
}
