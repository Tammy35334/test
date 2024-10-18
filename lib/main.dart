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
import 'repositories/likes_repository.dart';
import 'blocs/likes_bloc.dart';
import 'screens/market_page.dart';
import 'screens/flyers_page.dart';
import 'models/product.dart';
import 'models/store.dart';
import 'models/like.dart';
import 'storage/likes_storage_interface.dart';
import 'storage/flyers_storage_interface.dart';
import 'utils/logger.dart';
import 'widgets/likes_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Logger
  setupLogger();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(StoreAdapter());
  Hive.registerAdapter(LikeAdapter());

  // Initialize Storage
  StorageInterface productStorage = await StorageFactory.getProductStorage('productsBox');
  FlyersStorageInterface flyersStorage = await StorageFactory.getFlyersStorage('flyersBox');
  LikesStorageInterface likesStorage = await StorageFactory.getLikesStorage('likesBox');

  // Initialize Repositories
  ProductRepository productRepository = ProductRepository(
    httpClient: http.Client(),
    storage: productStorage,
  );

  FlyersRepository flyersRepository = FlyersRepository(
    httpClient: http.Client(),
    storage: flyersStorage,
  );

  LikesRepository likesRepository = LikesRepository(
    storage: likesStorage,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: productRepository),
        Provider<FlyersRepository>.value(value: flyersRepository),
        Provider<LikesRepository>.value(value: likesRepository),
        BlocProvider<LikesBloc>(
          create: (context) => LikesBloc(repository: likesRepository)..add(LoadLikesEvent()),
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

  void _openLikesDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: LikesDrawer(),
      ),
    );
  }

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
      floatingActionButton: FloatingActionButton(
        onPressed: _openLikesDrawer,
        tooltip: 'Likes',
        child: const Icon(Icons.pets),
      ),
    );
  }
}
