// lib/src/presentation/screens/doctor/doctor_add_prescription_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/prescription_repository.dart';
import '../../state/auth_provider.dart';

class DoctorAddPrescriptionScreen extends StatefulWidget {
  final String medication;
  final String dosage;
  final String duration;

  const DoctorAddPrescriptionScreen({
    super.key,
    this.medication = '',
    this.dosage = '',
    this.duration = '',
  });

  @override
  State<DoctorAddPrescriptionScreen> createState() =>
      _DoctorAddPrescriptionScreenState();
}

class _DoctorAddPrescriptionScreenState
    extends State<DoctorAddPrescriptionScreen> {
  late TextEditingController _medicationController;
  late TextEditingController _dosageController;
  late TextEditingController _durationController;

  bool _isSaving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _medicationController = TextEditingController(text: widget.medication);
    _dosageController = TextEditingController(text: widget.dosage);
    _durationController = TextEditingController(text: widget.duration);
  }

  Future<void> _savePrescription() async {
    final prescriptionRepository = context.read<PrescriptionRepository>();
    setState(() {
      _isSaving = true;
      _message = null;
    });

    final success = await prescriptionRepository.addPrescription('patient123', {
      'patientId': 'patient123',
      'medications': [
        {
          'name': _medicationController.text.trim(),
          'dosage': _dosageController.text.trim(),
          'duration': _durationController.text.trim(),
        },
      ],
      'scannedAt': DateTime.now().toIso8601String(),
    });

    setState(() {
      _isSaving = false;
      _message = success
          ? "Prescription créée avec succès !"
          : "Échec de la création de la prescription.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Valider la Prescription")),
      drawer: _buildDoctorDrawer(context, authProvider),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              if (_message != null)
                Text(_message!,
                    style: const TextStyle(color: Colors.green)),
              TextField(
                controller: _medicationController,
                decoration:
                const InputDecoration(labelText: "Médicament"),
              ),
              TextField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: "Dosage"),
              ),
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: "Durée"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePrescription,
                child: const Text("Valider la Prescription"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- Version du Drawer identique à doctor_home_screen.dart --
  Drawer _buildDoctorDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu Médecin',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
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
            leading: const Icon(Icons.note_add),
            title: const Text('Ajouter une Prescription'),
            onTap: () {
              Navigator.pop(context);
              // OCR text vide
              context.go('/doctor_add_prescription?ocrText=');
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