// lib/blocs/drawing_bloc.dart

import 'package:bloc/bloc.dart';
import '../models/drawn_line.dart';
import '../storage/drawing_storage_interface.dart';
import 'drawing_event.dart';
import 'drawing_state.dart';
import '../utils/logger.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  final DrawingStorageInterface drawingStorage;

  DrawingBloc({required this.drawingStorage}) : super(DrawingInitial()) {
    on<LoadDrawingsEvent>(_onLoadDrawings);
    on<AddDrawingEvent>(_onAddDrawing);
    on<ClearDrawingsEvent>(_onClearDrawings);
  }

  Future<void> _onLoadDrawings(
      LoadDrawingsEvent event, Emitter<DrawingState> emit) async {
    try {
      final drawings = await drawingStorage.getDrawings(event.imageId);
      emit(DrawingLoaded(drawings: drawings));
      logger.info(
          'Loaded ${drawings.length} drawings for imageId: ${event.imageId}');
    } catch (e) {
      emit(DrawingError(message: e.toString()));
      logger.severe('Error loading drawings: $e');
    }
  }

  Future<void> _onAddDrawing(
      AddDrawingEvent event, Emitter<DrawingState> emit) async {
    if (state is DrawingLoaded) {
      try {
        final currentDrawings =
            List<DrawnLine>.from((state as DrawingLoaded).drawings);
        currentDrawings.add(event.drawnLine);
        await drawingStorage.saveDrawings(event.imageId, currentDrawings);
        emit(DrawingLoaded(drawings: currentDrawings));
        logger.info('Added a drawing for imageId: ${event.imageId}');
      } catch (e) {
        emit(DrawingError(message: e.toString()));
        logger.severe('Error adding drawing: $e');
      }
    } else {
      emit(DrawingError(
          message: 'Cannot add drawing when state is not DrawingLoaded'));
    }
  }

  Future<void> _onClearDrawings(
      ClearDrawingsEvent event, Emitter<DrawingState> emit) async {
    try {
      await drawingStorage.clearDrawings(event.imageId);
      emit(const DrawingLoaded(drawings: []));
      logger.info('Cleared drawings for imageId: ${event.imageId}');
    } catch (e) {
      emit(DrawingError(message: e.toString()));
      logger.severe('Error clearing drawings: $e');
    }
  }
}
