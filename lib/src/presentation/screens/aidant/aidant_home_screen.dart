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
      drawer: _buildAidantDrawer(context, authProvider),
      body: const Center(
        child: Text(
          "Bienvenue dans l'espace Aidant",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// 🛠️ **Drawer pour la navigation de l'Aidant**
  Drawer _buildAidantDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu Aidant',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu),
            title: const Text('Menu Aidant'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Informations Patient'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_patient_info');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_notifications');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
