// lib/widgets/drawings_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/drawing_bloc.dart';
import '../blocs/drawing_state.dart';
import '../models/drawn_line.dart';

class DrawingsDrawer extends StatelessWidget {
  final String imageId;

  const DrawingsDrawer({super.key, required this.imageId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Adjust height as needed
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: BlocBuilder<DrawingBloc, DrawingState>(
        builder: (context, state) {
          if (state is DrawingInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DrawingLoaded) {
            final List<DrawnLine> currentDrawings = state.drawings;

            if (currentDrawings.isEmpty) {
              return const Center(child: Text('No drawings yet.'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentDrawings.length,
              itemBuilder: (context, index) {
                final DrawnLine drawing = currentDrawings[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Optionally, implement functionality to navigate to a specific drawing
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.brush, color: Colors.blue, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          'Drawing ${index + 1}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${drawing.points.length ~/ 2} points',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is DrawingError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
