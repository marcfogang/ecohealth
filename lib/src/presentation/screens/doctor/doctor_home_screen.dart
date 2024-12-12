// lib/src/presentation/screens/doctor/doctor_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Médecin'),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: const Center(
        child: Text("Bienvenue Docteur"),
      ),
    );
  }
}
