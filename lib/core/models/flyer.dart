import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Flyer {
  @HiveField(0)
  final String storeId;
  
  @HiveField(1)
  final String storeName;
  
  @HiveField(2)
  final List<String> imageUrls;
  
  @HiveField(3)
  final DateTime validFrom;
  
  @HiveField(4)
  final DateTime validTo;
  
  @HiveField(5)
  final Map<String, List<MarkedItem>> userMarks;

  const Flyer({
    required this.storeId,
    required this.storeName,
    required this.imageUrls,
    required this.validFrom,
    required this.validTo,
    this.userMarks = const {},
  });

  factory Flyer.fromJson(Map<String, dynamic> json) {
    return Flyer(
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List),
      validFrom: DateTime.parse(json['valid_from'] as String),
      validTo: DateTime.parse(json['valid_to'] as String),
      userMarks: (json['user_marks'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List).map((e) => MarkedItem.fromJson(e)).toList(),
            ),
          ) ??
          {},
    );
  }
}

@HiveType(typeId: 2)
class MarkedItem {
  @HiveField(0)
  final double x;
  
  @HiveField(1)
  final double y;
  
  @HiveField(2)
  final double radius;
  
  @HiveField(3)
  final int pageIndex;
  
  @HiveField(4)
  final String note;

  const MarkedItem({
    required this.x,
    required this.y,
    required this.radius,
    required this.pageIndex,
    this.note = '',
  });

  factory MarkedItem.fromJson(Map<String, dynamic> json) {
    return MarkedItem(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      pageIndex: json['page_index'] as int,
      note: json['note'] as String? ?? '',
    );
  }
}
