import 'package:hive_flutter/hive_flutter.dart';
import '../models/drawing.dart';

class DrawingManager {
  static const String _drawingsBoxName = 'drawings';
  Box<Drawing>? _drawingsBox;

  Future<void> init() async {
    _drawingsBox = await Hive.openBox<Drawing>(_drawingsBoxName);
  }

  Future<void> saveDrawing(Drawing drawing) async {
    await _drawingsBox?.add(drawing);
  }

  List<Drawing> getDrawingsForStore(int storeId) {
    return _drawingsBox?.values
        .where((drawing) => drawing.storeId == storeId)
        .toList() ?? [];
  }

  List<Drawing> getDrawingsForPage(int storeId, int pageIndex) {
    return _drawingsBox?.values
        .where((drawing) => 
            drawing.storeId == storeId && 
            drawing.pageIndex == pageIndex)
        .toList() ?? [];
  }

  Map<DrawingPoint, int> getHeatmapData(int storeId) {
    final drawings = getDrawingsForStore(storeId);
    final heatmap = <DrawingPoint, int>{};
    
    for (final drawing in drawings) {
      heatmap.update(
        drawing.center,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    
    return heatmap;
  }
}
