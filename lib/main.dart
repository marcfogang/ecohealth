// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Routing & Theme
import 'src/utils/routing/app_router.dart';
import 'src/utils/theme/app_theme.dart';

// Local Storage
import 'src/data/local/local_storage.dart';

// Services
import 'src/data/services/auth_service.dart';
import 'src/data/services/prescription_service.dart';
import 'src/data/services/aidant_service.dart';
import 'src/data/services/appointment_service.dart';
import 'src/data/services/medication_api_service.dart';
import 'src/data/services/notifications_service.dart';

// Repositories
import 'src/data/repositories/auth_repository.dart';
import 'src/data/repositories/prescription_repository.dart';
import 'src/data/repositories/aidant_repository.dart';
import 'src/data/repositories/appointment_repository.dart';
import 'src/data/repositories/stock_repository.dart';
import 'src/data/repositories/reminders_repository.dart';
import 'src/data/repositories/notifications_repository.dart';

// Providers
import 'src/presentation/state/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();


  // ✅ Ouvrir des boxes Hive pour stocker les données localement
  var userBox = await Hive.openBox('usersBox');
  var prescriptionBox = await Hive.openBox('prescriptionsBox');
  var appointmentBox = await Hive.openBox('appointmentsBox');
  var aidantBox = await Hive.openBox('aidantsBox');
  var remindersBox = await Hive.openBox('remindersBox');
  var notificationsBox = await Hive.openBox('notificationsBox'); // ✅ Ajout NotificationsBox

  // ✅ Initialisation du stockage Hive si nécessaire
  await LocalStorage.initHive();

  // ✅ Création des Services & Repositories

  // Auth
  final authService = AuthService(userBox: userBox);
  final authRepository = AuthRepository(authService: authService, userBox: userBox);

  // Prescriptions
  final prescriptionService = PrescriptionService(prescriptionBox: prescriptionBox);
  final prescriptionRepository = PrescriptionRepository(
    prescriptionService: prescriptionService,
    prescriptionBox: prescriptionBox,
  );

  // Aidants
  final aidantService = AidantService(aidantBox: aidantBox);
  final aidantRepository = AidantRepository(
    aidantService: aidantService,
    aidantBox: aidantBox,
  );

  // Appointments
  final appointmentService = AppointmentService(appointmentBox: appointmentBox);
  final appointmentRepository = AppointmentRepository(
    appointmentService: appointmentService,
    appointmentBox: appointmentBox,
  );

  // Stocks
  final stockRepository = StockRepository();

  // Medication API
  final medicationApiService = MedicationApiService();

  // Notifications
  final notificationService = NotificationService();
  await notificationService.initializeNotifications();
  await notificationService.requestNotificationPermissions();

  // Notifications Repository
  final notificationsRepository = NotificationsRepository(
    notificationsBox: notificationsBox,
  );

  // Reminders
  final remindersRepository = RemindersRepository(remindersBox: remindersBox);

  // ✅ Lancer l'application
  runApp(
    MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository: authRepository)),

        // Repositories
        Provider(create: (_) => prescriptionRepository),
        Provider(create: (_) => aidantRepository),
        Provider(create: (_) => appointmentRepository),
        Provider(create: (_) => stockRepository),
        Provider(create: (_) => remindersRepository),
        Provider(create: (_) => notificationsRepository), // ✅ Ajout NotificationsRepository

        // Services
        Provider(create: (_) => medicationApiService),
        Provider(create: (_) => notificationService),
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
