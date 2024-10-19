// lib/storage/storage_interface.dart

import 'package:hive/hive.dart';

abstract class StorageInterface<T extends HiveObject> {
  Future<void> addItem(T item);
  Future<void> updateItem(T item);
  Future<void> deleteItem(String id);
  Future<List<T>> getAllItems();
}
