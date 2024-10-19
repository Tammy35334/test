// lib/storage/drawing_storage_interface.dart

import '../models/drawn_line.dart';

abstract class DrawingStorageInterface {
  Future<List<DrawnLine>> getDrawings(String imageId);
  Future<void> saveDrawings(String imageId, List<DrawnLine> drawings);
  Future<void> clearDrawings(String imageId);
}
