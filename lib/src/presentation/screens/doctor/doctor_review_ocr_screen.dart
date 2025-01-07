import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';

class DoctorReviewOCRScreen extends StatefulWidget {
  final String rawText;
  final String medication; // ex: "Nom du médicament"
  final String voieAdmin;  // ancien "dosage"
  final String formePharma; // ancien "duration"

  const DoctorReviewOCRScreen({
    super.key,
    required this.rawText,
    this.medication = '',
    this.voieAdmin = '',
    this.formePharma = '',
  });

  @override
  State<DoctorReviewOCRScreen> createState() => _DoctorReviewOCRScreenState();
}

class _DoctorReviewOCRScreenState extends State<DoctorReviewOCRScreen> {
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _voieAdminController = TextEditingController();
  final TextEditingController _formePharmaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialise les champs avec les valeurs passées en paramètre
    _medicationController.text = widget.medication;
    _voieAdminController.text = widget.voieAdmin;
    _formePharmaController.text = widget.formePharma;
  }

  void _confirmOCR() {
    final medication = _medicationController.text.trim();
    final voieAdmin = _voieAdminController.text.trim();
    final formePharma = _formePharmaController.text.trim();

    // Redirige avec les données ajustées
    context.go(
      '/doctor_add_prescription',
      extra: {
        'medication': medication,
        'voieAdmin': voieAdmin,
        'formePharma': formePharma,
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

            // -- Champ : Nom du médicament
            TextField(
              controller: _medicationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nom du Médicament",
              ),
            ),
            const SizedBox(height: 10),

            // -- Champ : Nom de la voie administrative
            TextField(
              controller: _voieAdminController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nom de la voie administrative",
              ),
            ),
            const SizedBox(height: 10),

            // -- Champ : Nom de la forme pharmaceutique
            TextField(
              controller: _formePharmaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nom de la forme pharmaceutique",
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

// Si vous désirez un Drawer cohérent, voici un exemple minimal :
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
        // ... Autres items si besoin ...
      ],
    ),
  );
}
