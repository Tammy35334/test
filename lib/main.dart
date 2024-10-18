// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'storage/storage_interface.dart';
import 'storage/storage_factory.dart';
import 'repositories/product_repository.dart';
import 'repositories/flyers_repository.dart';
import 'blocs/drawing_bloc.dart'; 
import 'blocs/drawing_event.dart'; 
import 'screens/market_page.dart';
import 'screens/flyers_page.dart';
import 'models/product.dart';
import 'models/store.dart';
import 'models/drawn_line.dart';
import 'storage/flyers_storage_interface.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Logger
  setupLogger();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters with unique typeIds
  Hive.registerAdapter(ProductAdapter()); // typeId = 0
  Hive.registerAdapter(StoreAdapter());   // typeId = 1
  Hive.registerAdapter(DrawnLineAdapter()); // typeId = 2

  // Open Hive boxes
  await Hive.openBox<Product>('productsBox');
  await Hive.openBox<Store>('flyersBox');
  await Hive.openBox<List<DrawnLine>>('drawingsBox'); // Open drawingsBox instead of likesBox

  // Initialize Storage
  StorageInterface productStorage = await StorageFactory.getProductStorage('productsBox');
  FlyersStorageInterface flyersStorage = await StorageFactory.getFlyersStorage('flyersBox');
  // Removed likesStorage initialization
  // LikesStorageInterface likesStorage = await StorageFactory.getLikesStorage('likesBox');

  // Initialize Repositories
  ProductRepository productRepository = ProductRepository(
    httpClient: http.Client(),
    storage: productStorage,
  );

  FlyersRepository flyersRepository = FlyersRepository(
    httpClient: http.Client(),
    storage: flyersStorage,
  );

  // Removed LikesRepository initialization
  // LikesRepository likesRepository = LikesRepository(
  //   storage: likesStorage,
  // );

  runApp(
    MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: productRepository),
        Provider<FlyersRepository>.value(value: flyersRepository),
        // Removed Provider<LikesRepository>
        // Provider<LikesRepository>.value(value: likesRepository),
        // Removed BlocProvider<LikesBloc>
        // BlocProvider<LikesBloc>(
        //   create: (context) => LikesBloc(repository: likesRepository)..add(LoadLikesEvent()),
        // ),
        // Added BlocProvider<DrawingBloc>
        BlocProvider<DrawingBloc>(
          create: (context) => DrawingBloc()..add(LoadDrawingsEvent()),
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
    MarketPage(),
    FlyersPage(),
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
      // Removed floatingActionButton as likes feature is removed
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _openLikesDrawer,
      //   tooltip: 'Likes',
      //   child: const Icon(Icons.pets),
      // ),
    );
  }
}
