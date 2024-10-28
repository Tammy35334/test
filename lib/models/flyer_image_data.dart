import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'flyer_image_data.g.dart';

@HiveType(typeId: 2)
class FlyerImageData extends HiveObject {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final List<int> imageBytes;

  @HiveField(2)
  final DateTime lastUpdated;

  FlyerImageData({
    required this.url,
    required this.imageBytes,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Uint8List get bytes => Uint8List.fromList(imageBytes);
}

