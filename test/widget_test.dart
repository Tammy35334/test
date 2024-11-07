import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:myapp/core/services/cache_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final cacheService = CacheService();
    await cacheService.init();
    
    await tester.pumpWidget(MyApp(cacheService: cacheService));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
