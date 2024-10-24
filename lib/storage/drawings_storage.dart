// lib/storage/drawings_storage.dart

import 'package:hive/hive.dart';
import '../models/drawn_line.dart';
import 'drawing_storage_interface.dart';
import '../utils/logger.dart';

class HiveDrawingStorage implements DrawingStorageInterface {
  final Box<List<DrawnLine>> drawingsBox;

  HiveDrawingStorage({required this.drawingsBox});

  @override
  Future<void> clearDrawings(int imageId) async {
    await drawingsBox.delete(imageId);
    logger.info('Cleared drawings for imageId: $imageId');
  }

  @override
  Future<List<DrawnLine>> getDrawings(int imageId) async {
    final drawingsList = drawingsBox.get(imageId);
    if (drawingsList == null) {
      return [];
    }
    return drawingsList.cast<DrawnLine>();
  }

  @override
  Future<void> saveDrawings(int imageId, List<DrawnLine> drawings) async {
    await drawingsBox.put(imageId, drawings);
    logger.info('Saved ${drawings.length} drawings for imageId: $imageId');
  }
}
