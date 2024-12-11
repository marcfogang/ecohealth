// lib/src/presentation/screens/common/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenu centré
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('logo.jpg', height: 100),
                const SizedBox(height: 50),
                // Bouton stylisé
                ElevatedButton(
                  onPressed: () {
                    // Navigation vers l'écran de login
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Aller dans Login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
