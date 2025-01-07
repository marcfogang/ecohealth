import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';

class DoctorReviewOCRScreen extends StatefulWidget {
  final String rawText;
  final String medication;
  final String dosage;
  final String duration;

  const DoctorReviewOCRScreen({
    super.key,
    required this.rawText,
    this.medication = '',
    this.dosage = '',
    this.duration = '',
  });

  @override
  State<DoctorReviewOCRScreen> createState() => _DoctorReviewOCRScreenState();
}

class _DoctorReviewOCRScreenState extends State<DoctorReviewOCRScreen> {
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _medicationController.text = widget.medication;
    _dosageController.text = widget.dosage;
    _durationController.text = widget.duration;
  }

  void _confirmOCR() {
    final medication = _medicationController.text.trim();
    final dosage = _dosageController.text.trim();
    final duration = _durationController.text.trim();

    // Rediriger avec les données ajustées
    context.go(
      '/doctor_add_prescription',
      extra: {
        'medication': medication,
        'dosage': dosage,
        'duration': duration,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vérification du Texte OCR")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Veuillez vérifier et ajuster les champs extraits :",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _medicationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Médicament",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Dosage",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Durée",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _confirmOCR,
              icon: const Icon(Icons.check),
              label: const Text("Confirmer et Continuer"),
            ),
          ],
        ),
      ),
    );
  }
}

Drawer _buildDoctorDrawer(BuildContext context, AuthProvider authProvider) {
  return Drawer(
    child: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.document_scanner),
          title: const Text('Scanner une Ordonnance'),
          onTap: () => context.go('/doctor_scan_prescription'),
        ),
        ListTile(
          leading: const Icon(Icons.note_add),
          title: const Text('Ajouter une Prescription'),
          onTap: () => context.go('/doctor_add_prescription'),
        ),
      ],
    ),
  );
}
