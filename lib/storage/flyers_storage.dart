// lib/storage/flyers_storage.dart

import 'package:hive/hive.dart';
import '../models/store.dart';
import 'flyers_storage_interface.dart';

class FlyersStorage implements FlyersStorageInterface {
  final Box<Store> flyersBox;

  FlyersStorage({required this.flyersBox});

  @override
  Future<void> cacheFlyers(List<Store> flyers) async {
    final Map<int, Store> flyersMap = { for (var f in flyers) f.storeId : f };
    await flyersBox.putAll(flyersMap);
  }

  @override
  Future<List<Store>> getCachedFlyers() async {
    return flyersBox.values.toList();
  }
}
