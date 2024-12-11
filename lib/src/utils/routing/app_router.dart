import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../presentation/screens/common/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/patient/patient_home_screen.dart';
import '../../presentation/screens/doctor/doctor_home_screen.dart';
import '../../presentation/screens/aidant/aidant_home_screen.dart';

// Vous pourrez plus tard conditionner la redirection en fonction du rôle
// Pour l'instant, mettons des routes simples.
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
  ],
  initialLocation: '/',
);
