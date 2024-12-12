// lib/src/presentation/screens/aidant/aidant_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';

class AidantHomeScreen extends StatelessWidget {
  const AidantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Aidant'),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
              // Retour à l’écran de login après déconnexion
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: const Center(
        child: Text("Bienvenue dans l'espace aidant"),
      ),
    );
  }
}
