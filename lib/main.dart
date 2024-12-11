import 'package:flutter/material.dart';
import 'src/utils/routing/app_router.dart';
import 'src/utils/theme/app_theme.dart';
import 'src/data/local/local_storage.dart'; // Import pour accéder à l'init Hive

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Hive via LocalStorage
  await LocalStorage.initHive(); // Appel de la méthode d'init depuis local_storage.dart

  runApp(const MyApp());
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
