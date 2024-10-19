// lib/blocs/drawing_state.dart

import 'package:equatable/equatable.dart';
import '../models/drawn_line.dart';

abstract class DrawingState extends Equatable {
  const DrawingState();

  @override
  List<Object?> get props => [];
}

class DrawingInitial extends DrawingState {}

class DrawingLoading extends DrawingState {} // Added

class DrawingLoaded extends DrawingState {
  final List<DrawnLine> drawings;

  const DrawingLoaded({required this.drawings});

  @override
  List<Object?> get props => [drawings];
}

class DrawingError extends DrawingState {
  final String message;

  const DrawingError({required this.message});

  @override
  List<Object?> get props => [message];
}
