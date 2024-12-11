import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import du provider
import 'src/utils/routing/app_router.dart';
import 'src/utils/theme/app_theme.dart';
import 'src/data/local/local_storage.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/repositories/auth_repository.dart';
import 'src/presentation/state/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Hive via LocalStorage
  await LocalStorage.initHive();

  // Instanciation du AuthService et du AuthRepository
  final authService = AuthService();
  final authRepository = AuthRepository(authService: authService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
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
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
