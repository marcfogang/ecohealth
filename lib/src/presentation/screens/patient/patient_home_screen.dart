// lib/src/presentation/screens/patient/patient_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Patient'),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
              // Après déconnexion, on retourne sur l’écran de login
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: const Center(
        child: Text("Bienvenue dans l'espace patient"),
      ),
    );
  }
}
