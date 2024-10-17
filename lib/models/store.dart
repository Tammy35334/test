// lib/models/store.dart

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Store {
  @HiveField(0)
  final int storeId;

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

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  Map<String, dynamic> toJson() => _$StoreToJson(this);
}
