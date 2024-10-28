import 'package:hive/hive.dart';

part 'flyer.g.dart';

@HiveType(typeId: 1)
class Flyer extends HiveObject {
  @HiveField(0)
  final int storeId;

  @HiveField(1)
  final String storeName;

  @HiveField(2)
  final String province;

  @HiveField(3)
  final List<String> flyerImages;

  @HiveField(4)
  final DateTime lastUpdated;

  Flyer({
    required this.storeId,
    required this.storeName,
    required this.province,
    required this.flyerImages,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory Flyer.fromJson(Map<String, dynamic> json) {
    return Flyer(
      storeId: json['storeId'] as int,
      storeName: json['storeName'] as String,
      province: json['province'] as String,
      flyerImages: List<String>.from(json['flyerImages'] as List),
    );
  }
}
