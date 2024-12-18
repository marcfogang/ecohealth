// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/utils/routing/app_router.dart';
import 'src/utils/theme/app_theme.dart';
import 'src/data/local/local_storage.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/repositories/auth_repository.dart';
import 'src/presentation/state/auth_provider.dart';

// Ajouts :
import 'src/data/services/prescription_service.dart';
import 'src/data/repositories/prescription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.initHive();

  final authService = AuthService();
  final authRepository = AuthRepository(authService: authService);

  // Création du PrescriptionService et PrescriptionRepository
  final prescriptionService = PrescriptionService();
  final prescriptionRepository = PrescriptionRepository(prescriptionService: prescriptionService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository: authRepository)),
        Provider(create: (_) => prescriptionRepository), // Fournir le prescriptionRepository
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
