// lib/models/store.dart

import 'package:hive/hive.dart';

part 'store.g.dart';

@HiveType(typeId: 1)
class Store extends HiveObject {
  @HiveField(0)
  final String storeId;

  @HiveField(1)
  final String storeName;

  @HiveField(2)
  final String province;

  @HiveField(3)
  final List<String> flyerImages;

  Store({
    required this.storeId,
    required this.storeName,
    required this.province,
    required this.flyerImages,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      province: json['province'] as String,
      flyerImages: List<String>.from(json['flyerImages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'storeName': storeName,
        'province': province,
        'flyerImages': flyerImages,
      };
}
