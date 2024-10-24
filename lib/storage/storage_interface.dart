// lib/storage/storage_interface.dart

import 'package:hive/hive.dart';

abstract class StorageInterface<T extends HiveObject> {
  Future<void> addItem(T item);
  Future<void> updateItem(T item);
  Future<void> deleteItem(int id);
  Future<List<T>> getAllItems();
  Future<void> cacheItems(List<T> items);
}
