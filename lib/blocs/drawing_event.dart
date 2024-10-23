// lib/blocs/drawing_event.dart

import 'package:equatable/equatable.dart';
import '../models/drawn_line.dart';

abstract class DrawingEvent extends Equatable {
  const DrawingEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadDrawingsEvent extends DrawingEvent {
  final String imageId;

  const LoadDrawingsEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class AddDrawingEvent extends DrawingEvent {
  final String imageId;
  final DrawnLine drawnLine;

  const AddDrawingEvent({required this.imageId, required this.drawnLine});

  @override
  List<Object?> get props => [imageId, drawnLine];
}

class ClearDrawingsEvent extends DrawingEvent {
  final String imageId;

  const ClearDrawingsEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}
