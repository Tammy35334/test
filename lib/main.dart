import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/flyer.dart';
import 'models/flyer_image_data.dart';
import 'models/emoji_reaction.dart';
import 'repositories/flyer_repository.dart';
import 'navigation/screens/main_navigation.dart';
import 'repositories/product_repository.dart';
import 'navigation/cubit/navigation_cubit.dart';
import 'services/emoji_reaction_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(FlyerAdapter());
  Hive.registerAdapter(FlyerImageDataAdapter());
  Hive.registerAdapter(EmojiTypeAdapter());
  Hive.registerAdapter(EmojiReactionAdapter());
  
  // Initialize repositories and services
  final flyerRepository = FlyerRepository();
  final emojiReactionManager = EmojiReactionManager();
  await emojiReactionManager.init();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => flyerRepository,
        ),
        RepositoryProvider(
          create: (context) => emojiReactionManager,
        ),
      ],
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
