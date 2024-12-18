// lib/src/presentation/screens/doctor/doctor_prescription_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';
import '../../../data/repositories/prescription_repository.dart';

class DoctorPrescriptionHistoryScreen extends StatelessWidget {
  const DoctorPrescriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final prescriptionRepository = context.read<PrescriptionRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text("Historique des Prescriptions")),
      drawer: _buildDoctorDrawer(context, authProvider),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: prescriptionRepository.loadPrescriptionHistory("patient123"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          final prescriptions = snapshot.data ?? [];
          if (prescriptions.isEmpty) {
            return const Center(child: Text("Aucune prescription trouvée."));
          }
          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final p = prescriptions[index];
              return ListTile(
                title: Text("Prescription: ${p['id']}"),
                subtitle: Text("Médicaments: ${p['medications'].map((m) => m['name']).join(', ')}"),
              );
            },
          );
        },
      ),
    );
  }

  Drawer _buildDoctorDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu Médecin', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner),
            title: const Text('Scanner une Ordonnance'),
            onTap: () {
              Navigator.pop(context);
              context.go('/doctor_scan_prescription');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historique des Prescriptions'),
            onTap: () {
              Navigator.pop(context);
              context.go('/doctor_prescription_history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Gestion des Aidants'),
            onTap: () {
              Navigator.pop(context);
              context.go('/doctor_manage_aidants');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Gestion des Rendez-vous'),
            onTap: () {
              Navigator.pop(context);
              context.go('/doctor_appointments');
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
