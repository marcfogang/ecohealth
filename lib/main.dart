// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/utils/routing/app_router.dart';
import 'src/utils/theme/app_theme.dart';
import 'src/data/local/local_storage.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/repositories/auth_repository.dart';
import 'src/presentation/state/auth_provider.dart';

import 'src/data/services/prescription_service.dart';
import 'src/data/repositories/prescription_repository.dart';

import 'src/data/services/aidant_service.dart';
import 'src/data/repositories/aidant_repository.dart';

import 'src/data/services/appointment_service.dart';
import 'src/data/repositories/appointment_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Ouvrir des boxes Hive pour stocker les données localement
  // Exemple: utilisateurs, prescriptions, rendez-vous, etc.
  var userBox = await Hive.openBox('usersBox');
  var prescriptionBox = await Hive.openBox('prescriptionsBox');
  var appointmentBox = await Hive.openBox('appointmentsBox');
  var aidantBox = await Hive.openBox('aidantsBox');

  await LocalStorage.initHive();

  final authService = AuthService(userBox: userBox);
  final authRepository = AuthRepository(authService: authService, userBox: userBox);

  final prescriptionService = PrescriptionService(prescriptionBox: prescriptionBox);
  final prescriptionRepository = PrescriptionRepository(prescriptionService: prescriptionService, prescriptionBox: prescriptionBox);

  final aidantService = AidantService(aidantBox: aidantBox);
  final aidantRepository = AidantRepository(aidantService: aidantService, aidantBox: aidantBox);

  final appointmentService = AppointmentService(appointmentBox: appointmentBox);
  final appointmentRepository = AppointmentRepository(appointmentService: appointmentService, appointmentBox: appointmentBox);

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
