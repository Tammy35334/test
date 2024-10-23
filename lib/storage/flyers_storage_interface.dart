// lib/storage/flyers_storage_interface.dart

import '../models/store.dart';

abstract class FlyersStorageInterface {
  Future<void> cacheFlyers(List<Store> flyers);
  Future<List<Store>> getCachedFlyers();
  Future<void> addFlyer(Store flyer);
  Future<void> updateFlyer(Store flyer);
  Future<void> deleteFlyer(int id); // Changed from String to int
}
