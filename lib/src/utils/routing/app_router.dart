// lib/src/utils/routing/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../presentation/screens/common/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/patient/patient_home_screen.dart';
import '../../presentation/screens/doctor/doctor_home_screen.dart';
import '../../presentation/screens/aidant/aidant_home_screen.dart';
import '../../presentation/screens/doctor/doctor_scan_prescription_screen.dart';
import '../../presentation/screens/doctor/doctor_add_prescription_screen.dart';
import '../../presentation/screens/doctor/doctor_prescription_history_screen.dart';
import '../../presentation/screens/doctor/doctor_manage_aidants_screen.dart';
import '../../presentation/screens/doctor/doctor_appointments_screen.dart';
import '../../presentation/screens/doctor/doctor_review_ocr_screen.dart';

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
    GoRoute(
      path: '/doctor_scan_prescription',
      name: 'doctor_scan_prescription',
      builder: (context, state) => const DoctorScanPrescriptionScreen(),
    ),
    GoRoute(
      path: '/doctor_add_prescription',
      name: 'doctor_add_prescription',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return DoctorAddPrescriptionScreen(
          medication: extra['medication'] ?? '',
          dosage: extra['dosage'] ?? '',
          duration: extra['duration'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/doctor_prescription_history',
      name: 'doctor_prescription_history',
      builder: (context, state) => const DoctorPrescriptionHistoryScreen(),
    ),
    GoRoute(
      path: '/doctor_manage_aidants',
      name: 'doctor_manage_aidants',
      builder: (context, state) => const DoctorManageAidantsScreen(),
    ),
    GoRoute(
      path: '/doctor_appointments',
      name: 'doctor_appointments',
      builder: (context, state) => const DoctorAppointmentsScreen(),
    ),
    GoRoute(
      path: '/doctor_review_ocr',
      name: 'doctor_review_ocr',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return DoctorReviewOCRScreen(
          rawText: extra['rawText'] ?? '',
          medication: extra['medication'] ?? '',
          dosage: extra['dosage'] ?? '',
          duration: extra['duration'] ?? '',
        );
      },
    ),
  ],
  initialLocation: '/',
);
