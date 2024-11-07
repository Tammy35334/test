import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation/cubit/navigation_cubit.dart';
import 'navigation/screens/main_navigation.dart';
import 'repositories/flyer_repository.dart';
import 'core/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cache service
  final cacheService = CacheService();
  await cacheService.init();

  runApp(MyApp(cacheService: cacheService));
}

class MyApp extends StatelessWidget {
  final CacheService cacheService;

  const MyApp({
    super.key,
    required this.cacheService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => FlyerRepository(cacheService),
        ),
      ],
      child: BlocProvider(
        create: (context) => NavigationCubit(),
        child: MaterialApp(
          title: 'Shopping App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MainNavigation(),
        ),
      ),
    );
  }
}
