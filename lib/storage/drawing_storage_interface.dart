// lib/storage/drawing_storage_interface.dart

import '../models/drawn_line.dart';

abstract class DrawingStorageInterface {
  Future<List<DrawnLine>> getDrawings(int imageId);
  Future<void> saveDrawings(int imageId, List<DrawnLine> drawings);
  Future<void> clearDrawings(int imageId);
}
