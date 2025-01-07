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
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      drawer: _buildPatientDrawer(context),
      body: const Center(
        child: Text("Bienvenue dans l'espace patient"),
      ),
    );
  }

  /// Drawer permettant de naviguer vers les écrans Patient
  Drawer _buildPatientDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu Patient',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Mes Prescriptions'),
            onTap: () {
              Navigator.pop(context);
              context.go('/patient_prescriptions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Mes Rendez-vous'),
            onTap: () {
              Navigator.pop(context);
              context.go('/patient_appointments');
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Mon Stock'),
            onTap: () {
              Navigator.pop(context);
              context.go('/patient_stock');
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Mes Rappels'),
            onTap: () {
              Navigator.pop(context);
              context.go('/patient_reminders');
            },
          ),
        ],
      ),
    );
  }
}
