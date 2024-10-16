import 'package:flutter/material.dart';
import 'screens/market_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp()); // Added const for performance
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Added key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(), // Apply Roboto font globally
      ),
      home: const MarketPage(), // Added const for performance
    );
  }
}
