// lib/widgets/error_indicator.dart

import 'package:flutter/material.dart';

class ErrorIndicator extends StatelessWidget {
  final String error;
  final VoidCallback onTryAgain;

  const ErrorIndicator({super.key, required this.error, required this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'An error occurred:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTryAgain,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
