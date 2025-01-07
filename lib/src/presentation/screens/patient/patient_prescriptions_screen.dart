// lib/src/presentation/screens/patient/patient_prescriptions_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Supposons que vous ayez un PrescriptionRepository déjà défini
import '../../../data/repositories/prescription_repository.dart';
import '../../state/auth_provider.dart';

class PatientPrescriptionsScreen extends StatefulWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  State<PatientPrescriptionsScreen> createState() =>
      _PatientPrescriptionsScreenState();
}

class _PatientPrescriptionsScreenState
    extends State<PatientPrescriptionsScreen> {
  late Future<List<Map<String, dynamic>>> _futurePrescriptions;

  @override
  void initState() {
    super.initState();
    // On récupère le patientId (ex: depuis authProvider ?)
    final patientId = "patient123"; // ou context.read<AuthProvider>().userId
    final prescriptionRepo = context.read<PrescriptionRepository>();

    // Charge les prescriptions locales (Hive) pour l’instant
    _futurePrescriptions =
        prescriptionRepo.loadPrescriptionHistory(patientId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Prescriptions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: _buildPatientDrawer(context, authProvider),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futurePrescriptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Erreur : ${snapshot.error}"),
            );
          }

          final prescriptions = snapshot.data ?? [];
          if (prescriptions.isEmpty) {
            return const Center(child: Text("Aucune prescription trouvée."));
          }

          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final p = prescriptions[index];
              final id = p['id'];
              final medication = p['medications'][0]['name'] ?? 'Inconnu';

              return ListTile(
                title: Text("Prescription #$id"),
                subtitle: Text("Médicament : $medication"),
                onTap: () => _showPrescriptionDetails(p),
              );
            },
          );
        },
      ),
    );
  }

  /// Pop-up d’exemple pour afficher plus d’infos sur la prescription
  void _showPrescriptionDetails(Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (ctx) {
        final meds = prescription['medications'] as List<dynamic>;
        final medicationName = meds.isNotEmpty ? meds[0]['name'] : 'Inconnu';
        final voie = meds.isNotEmpty ? meds[0]['voie_administrative'] ?? '' : '';
        final forme = meds.isNotEmpty ? meds[0]['forme_pharmaceutique'] ?? '' : '';

        return AlertDialog(
          title: Text("Détails Prescription #${prescription['id']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Médicament : $medicationName"),
              Text("Voie : $voie"),
              Text("Forme : $forme"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Fermer"),
            )
          ],
        );
      },
    );
  }

  /// Drawer identique Patient
  Drawer _buildPatientDrawer(BuildContext context, AuthProvider authProvider) {
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
