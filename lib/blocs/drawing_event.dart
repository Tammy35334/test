// lib/blocs/drawing_event.dart

import 'package:equatable/equatable.dart';
import '../models/drawing.dart';

abstract class DrawingEvent extends Equatable {
  const DrawingEvent();

  @override
  List<Object?> get props => [];
}

class LoadDrawingsEvent extends DrawingEvent {}

class AddDrawingEvent extends DrawingEvent {
  final Drawing drawing;

  const AddDrawingEvent({required this.drawing});

  @override
  List<Object?> get props => [drawing];
}

class RemoveDrawingEvent extends DrawingEvent {
  final String drawingId;

  const RemoveDrawingEvent({required this.drawingId});

  @override
  List<Object?> get props => [drawingId];
}
