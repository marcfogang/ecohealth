// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/utils/routing/app_router.dart';
import 'src/utils/theme/app_theme.dart';
import 'src/data/local/local_storage.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/repositories/auth_repository.dart';
import 'src/presentation/state/auth_provider.dart';

// Import des nouveaux services et repositories
import 'src/data/services/prescription_service.dart';
import 'src/data/repositories/prescription_repository.dart';

import 'src/data/services/aidant_service.dart';
import 'src/data/repositories/aidant_repository.dart';

import 'src/data/services/appointment_service.dart';
import 'src/data/repositories/appointment_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.initHive();

  final authService = AuthService();
  final authRepository = AuthRepository(authService: authService);

  final prescriptionService = PrescriptionService();
  final prescriptionRepository = PrescriptionRepository(prescriptionService: prescriptionService);

  final aidantService = AidantService();
  final aidantRepository = AidantRepository(aidantService: aidantService);

  final appointmentService = AppointmentService();
  final appointmentRepository = AppointmentRepository(appointmentService: appointmentService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository: authRepository)),
        Provider(create: (_) => prescriptionRepository),
        Provider(create: (_) => aidantRepository),
        Provider(create: (_) => appointmentRepository),
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
