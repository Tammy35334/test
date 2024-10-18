// lib/blocs/drawing_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'drawing_event.dart';
import 'drawing_state.dart';
import '../models/drawing.dart';
import 'package:hive/hive.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  DrawingBloc() : super(DrawingInitial()) {
    on<LoadDrawingsEvent>(_onLoadDrawings);
    on<AddDrawingEvent>(_onAddDrawing);
    on<RemoveDrawingEvent>(_onRemoveDrawing);
  }

  final Box<Drawing> _drawingBox = Hive.box<Drawing>('drawingsBox');

  void _onLoadDrawings(LoadDrawingsEvent event, Emitter<DrawingState> emit) {
    emit(DrawingLoading());
    try {
      final drawings = _drawingBox.values.toList();
      emit(DrawingLoaded(drawings: drawings));
    } catch (e) {
      emit(DrawingError(message: e.toString()));
    }
  }

  void _onAddDrawing(AddDrawingEvent event, Emitter<DrawingState> emit) {
    _drawingBox.put(event.drawing.id, event.drawing);
    add(LoadDrawingsEvent());
  }

  void _onRemoveDrawing(RemoveDrawingEvent event, Emitter<DrawingState> emit) {
    _drawingBox.delete(event.drawingId);
    add(LoadDrawingsEvent());
  }
}
