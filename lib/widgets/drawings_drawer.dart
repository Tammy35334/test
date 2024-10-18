// lib/widgets/drawings_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/drawing_bloc.dart';
import '../blocs/drawing_state.dart';
import '../models/drawing.dart';

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
          if (state is DrawingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DrawingLoaded) {
            // Filter drawings for the current image
            List<Drawing> currentDrawings = state.drawings
                .where((drawing) => drawing.imageId == imageId)
                .toList();

            if (currentDrawings.isEmpty) {
              return const Center(child: Text('No drawings yet.'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentDrawings.length,
              itemBuilder: (context, index) {
                final Drawing drawing = currentDrawings[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: Colors.blue, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        '(${drawing.center.dx.toStringAsFixed(1)}, ${drawing.center.dy.toStringAsFixed(1)})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
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
