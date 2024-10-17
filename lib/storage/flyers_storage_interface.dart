// lib/storage/flyers_storage_interface.dart

import '../models/store.dart';

abstract class FlyersStorageInterface {
  Future<void> cacheFlyers(List<Store> flyers);
  Future<List<Store>> getCachedFlyers();
}
