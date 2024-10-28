import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/flyer.dart';
import 'models/flyer_image_data.dart';
import 'repositories/flyer_repository.dart';
import 'navigation/screens/main_navigation.dart';
import 'repositories/product_repository.dart';
import 'navigation/cubit/navigation_cubit.dart';
import 'models/drawing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(FlyerAdapter());
  Hive.registerAdapter(FlyerImageDataAdapter());
  Hive.registerAdapter(DrawingAdapter());
  Hive.registerAdapter(DrawingPointAdapter());
  
  final flyerRepository = FlyerRepository();
  
  runApp(
    BlocProvider(
      create: (context) => flyerRepository,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ProductRepository()),
        RepositoryProvider(create: (context) => FlyerRepository()),
      ],
      child: BlocProvider(
        create: (context) => NavigationCubit(),
        child: MaterialApp(
          title: 'Grocery App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const MainNavigation(),
        ),
      ),
    );
  }
}
