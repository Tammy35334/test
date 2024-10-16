// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart'; // Ensure the correct import path

void main() {
  testWidgets('MarketPage displays products', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the AppBar title is present.
    expect(find.text('Market'), findsOneWidget);

    // Wait for products to load (assuming network call takes some time)
    await tester.pump(const Duration(seconds: 2));

    // Verify that a product item is displayed.
    expect(find.byType(ListTile), findsWidgets);

    // You can add more specific tests here, e.g., check for a specific product name.
  });
}
