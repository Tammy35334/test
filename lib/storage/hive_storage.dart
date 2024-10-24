// lib/storage/hive_storage.dart

import 'package:hive/hive.dart';
import '../storage/storage_interface.dart';
import '../utils/logger.dart';

class HiveStorage<T extends HiveObject> implements StorageInterface<T> {
  final Box<T> box;

  HiveStorage({required this.box});

  @override
  Future<void> addItem(T item) async {
    final int id = item.key as int; // Assuming key is int
    await box.put(id, item);
    logger.info('Item added with ID: $id');
  }

  @override
  Future<void> updateItem(T item) async {
    await item.save();
    logger.info('Item updated with ID: ${item.key}');
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
    final Map<int, T> itemsMap = {for (var item in items) item.key as int: item};
    await box.putAll(itemsMap);
    logger.info('Cached ${items.length} items.');
  }
}
