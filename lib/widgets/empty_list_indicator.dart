// lib/widgets/empty_list_indicator.dart

import 'package:flutter/material.dart';

class EmptyListIndicator extends StatelessWidget {
  const EmptyListIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No items found.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
