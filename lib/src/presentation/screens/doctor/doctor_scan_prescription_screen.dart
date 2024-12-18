// lib/src/presentation/screens/doctor/doctor_scan_prescription_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/prescription_repository.dart';
import '../../state/auth_provider.dart';

class DoctorScanPrescriptionScreen extends StatefulWidget {
  const DoctorScanPrescriptionScreen({super.key});

  @override
  State<DoctorScanPrescriptionScreen> createState() => _DoctorScanPrescriptionScreenState();
}

class _DoctorScanPrescriptionScreenState extends State<DoctorScanPrescriptionScreen> {
  bool _isScanning = false;
  bool _scanCompleted = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final prescriptionRepository = context.read<PrescriptionRepository>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner une Ordonnance"),
      ),
      drawer: _buildDoctorDrawer(context, authProvider),
      body: Center(
        child: _isScanning
            ? const CircularProgressIndicator()
            : _scanCompleted && _message != null
                ? Text(_message!)
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isScanning = true;
                        _scanCompleted = false;
                        _message = null;
                      });

                      await Future.delayed(const Duration(seconds: 2));

                      final prescriptionData = {
                        'patientId': 'patient123',
                        'medications': [
                          {'name': 'Paracetamol', 'dosage': '500mg', 'duration': '5 days'},
                        ],
                        'scannedAt': DateTime.now().toIso8601String(),
                      };

                      final success = await prescriptionRepository.addPrescription('patient123', prescriptionData);

                      setState(() {
                        _isScanning = false;
                        _scanCompleted = true;
                        _message = success
                            ? "Scan effectué et prescription ajoutée avec succès !"
                            : "Échec de l'ajout de la prescription.";
                      });
                    },
                    child: const Text("Scanner une Ordonnance"),
                  ),
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
