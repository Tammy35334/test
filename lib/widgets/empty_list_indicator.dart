// lib/widgets/empty_list_indicator.dart

import 'package:flutter/material.dart';

class EmptyListIndicator extends StatelessWidget {
  const EmptyListIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No flyers found.',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
