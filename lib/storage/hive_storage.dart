// lib/storage/hive_storage.dart

import 'package:hive/hive.dart';
import '../storage/storage_interface.dart';

class HiveStorage<T extends HiveObject> implements StorageInterface<T> {
  final Box<T> box;

  HiveStorage({required this.box});

  @override
  Future<void> addItem(T item) async {
    await box.put(item.key, item);
  }

  @override
  Future<void> updateItem(T item) async {
    await item.save();
  }

  @override
  Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  @override
  Future<List<T>> getAllItems() async {
    return box.values.toList();
  }
}
