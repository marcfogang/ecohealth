// lib/src/presentation/screens/common/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigation vers l'écran de login
            context.go('/login');
          },
          child: const Text('Aller dans Login'),
        ),
      ),
    );
  }
}
