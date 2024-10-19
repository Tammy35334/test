// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'storage/drawing_storage_interface.dart';
import 'storage/drawings_storage.dart';
import 'storage/hive_storage.dart';
import 'storage/flyers_storage.dart';
import 'repositories/product_repository.dart';
import 'repositories/flyers_repository.dart';
import 'blocs/drawing_bloc.dart';
import 'screens/market_page.dart';
import 'screens/flyers_page.dart';
import 'models/product.dart';
import 'models/store.dart';
import 'models/drawn_line.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Logger
  setupLogger();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register Hive adapters with unique typeIds
  Hive.registerAdapter(ProductAdapter()); // typeId = 0
  Hive.registerAdapter(StoreAdapter());   // typeId = 1
  Hive.registerAdapter(DrawnLineAdapter()); // typeId = 2

  // Open Hive boxes
  await Hive.openBox<Product>('productsBox');
  await Hive.openBox<Store>('flyersBox');
  await Hive.openBox<List<DrawnLine>>('drawingsBox');

  // Initialize DrawingStorageInterface directly
  final drawingsBox = Hive.box<List<DrawnLine>>('drawingsBox');
  final drawingStorage = HiveDrawingStorage(drawingsBox: drawingsBox);

  // Initialize ProductStorage
  final productBox = Hive.box<Product>('productsBox');
  final productStorage = HiveStorage<Product>(box: productBox);

  // Initialize FlyersStorage
  final flyersBox = Hive.box<Store>('flyersBox');
  final flyersStorage = FlyersStorage(flyersBox: flyersBox);

  // Initialize Repositories
  final productRepository = ProductRepository(
    httpClient: http.Client(),
    storage: productStorage,
  );

  final flyersRepository = FlyersRepository(
    httpClient: http.Client(),
    storage: flyersStorage,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: productRepository),
        Provider<FlyersRepository>.value(value: flyersRepository),
        Provider<DrawingStorageInterface>.value(value: drawingStorage),
        BlocProvider<DrawingBloc>(
          create: (context) => DrawingBloc(drawingStorage: drawingStorage),
        ),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Using super.key for constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M1G1R2 Market & Flyers',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          titleTextStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system, // Adapts to system theme
      home: const HomePage(),
      routes: {
        FlyersPage.routeName: (context) => const FlyersPage(),
        // Add other routes here if needed
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Initialize the pages once to preserve their state
  late final List<Widget> _pages = [
    const MarketPage(),
    const FlyersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Removed _openLikesDrawer method as likes feature is removed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews), // Choose an appropriate icon
            label: 'Flyers',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Customize as needed
        onTap: _onItemTapped,
      ),
    );
  }
}
