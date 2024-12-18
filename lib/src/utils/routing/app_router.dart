// lib/src/utils/routing/app_router.dart

import 'package:go_router/go_router.dart';

import '../../presentation/screens/common/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/patient/patient_home_screen.dart';
import '../../presentation/screens/doctor/doctor_home_screen.dart';
import '../../presentation/screens/aidant/aidant_home_screen.dart';
import '../../presentation/screens/doctor/doctor_scan_prescription_screen.dart'; // Import du nouvel écran

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/patient_home',
      name: 'patient_home',
      builder: (context, state) => const PatientHomeScreen(),
    ),
    GoRoute(
      path: '/doctor_home',
      name: 'doctor_home',
      builder: (context, state) => const DoctorHomeScreen(),
    ),
    GoRoute(
      path: '/aidant_home',
      name: 'aidant_home',
      builder: (context, state) => const AidantHomeScreen(),
    ),
    // Nouvelle route pour le scan ordonnance
    GoRoute(
      path: '/doctor_scan_prescription',
      name: 'doctor_scan_prescription',
      builder: (context, state) => const DoctorScanPrescriptionScreen(),
    ),
  ],
  initialLocation: '/',
);
