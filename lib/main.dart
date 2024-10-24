// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'storage/drawing_storage_interface.dart';
import 'storage/drawings_storage.dart';
import 'storage/hive_storage.dart';
import 'storage/flyers_storage.dart';
import 'repositories/product_repository.dart';
import 'repositories/flyers_repository.dart';
import 'blocs/drawing_bloc.dart';
import 'models/product.dart';
import 'models/store.dart';
import 'models/drawn_line.dart';
import 'models/metadata_storage.dart';
import 'utils/logger.dart';
import 'screens/home_page.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Commented Out)
  // Uncomment and configure Firebase if needed
  /*
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  */

  // Setup Logger
  setupLogger();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register Hive adapters with unique typeIds
  Hive.registerAdapter(ProductAdapter()); // typeId = 0
  Hive.registerAdapter(StoreAdapter());   // typeId = 1
  Hive.registerAdapter(DrawnLineAdapter()); // typeId = 2
  Hive.registerAdapter(MetadataAdapter()); // typeId = 4

  // Open Hive boxes
  await Hive.openBox<Product>('productsBox');
  await Hive.openBox<Store>('flyersBox');
  await Hive.openBox<List<DrawnLine>>('drawingsBox');
  await Hive.openBox<Metadata>('metadataBox'); // Metadata box

  // Initialize Storage Interfaces
  final drawingsBox = Hive.box<List<DrawnLine>>('drawingsBox');
  final drawingStorage = HiveDrawingStorage(drawingsBox: drawingsBox);

  final productBox = Hive.box<Product>('productsBox');
  final productStorage = HiveStorage<Product>(box: productBox);

  final flyersBox = Hive.box<Store>('flyersBox');
  final flyersStorage = FlyersStorage(flyersBox: flyersBox);

  // Removed metadataBox as it's not needed in FlyersRepository
  // final metadataBox = Hive.box<Metadata>('metadataBox');

  // Initialize Repositories
  final productRepository = ProductRepository(
    httpClient: http.Client(),
    storage: productStorage,
  );

  final flyersRepository = FlyersRepository(
    httpClient: http.Client(),
    storage: flyersStorage,
    // metadataBox: metadataBox, // Removed this line
  );

  // Initialize Analytics Service (Commented Out)
  // Uncomment and configure Firebase Analytics if needed
  //final analytics = FirebaseAnalytics.instance;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>.value(value: productRepository),
        RepositoryProvider<FlyersRepository>.value(value: flyersRepository),
        RepositoryProvider<DrawingStorageInterface>.value(value: drawingStorage),
        // RepositoryProvider<FirebaseAnalytics>.value(value: analytics), // Uncomment if using Firebase Analytics
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DrawingBloc>(
            create: (context) => DrawingBloc(drawingStorage: drawingStorage),
          ),
          // Add other Blocs here if needed
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Using super.key for constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M1G1R2 Market & Flyers',
      theme: AppThemes.lightTheme, // Apply Light Theme
      darkTheme: AppThemes.darkTheme, // Apply Dark Theme
      themeMode: ThemeMode.system, // Adapts to system theme
      home: const HomePage(),
      routes: {
        // Define routes for other pages if needed
        // FlyersPage.routeName: (context) => const FlyersPage(),
        // ProfilePage.routeName: (context) => const ProfilePage(),
      },
    );
  }
}
