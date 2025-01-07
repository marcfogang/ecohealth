// lib/src/presentation/screens/doctor/doctor_scan_prescription_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import '../../state/auth_provider.dart';

class DoctorScanPrescriptionScreen extends StatefulWidget {
  const DoctorScanPrescriptionScreen({super.key});

  @override
  State<DoctorScanPrescriptionScreen> createState() =>
      _DoctorScanPrescriptionScreenState();
}

class _DoctorScanPrescriptionScreenState
    extends State<DoctorScanPrescriptionScreen> {
  bool _isScanning = false;
  File? _selectedImage;
  String? _ocrError;

  // Méthodes de Parsing Automatique
  /// Renvoie le nom du médicament (Médicament / Medicine)
  String _parseMedication(String text) {
    final regex = RegExp(r"(Médicament|Medicine):\s*(\w+)");
    final match = regex.firstMatch(text);
    return match?.group(2) ?? '';
  }

  /// Renvoie le nom de la voie administrative (ancien "dosage")
  String _parseVoieAdmin(String text) {
    // On suppose qu'il y a un tag "VoieAdmin" ou "Dose" ou "Dosage" :
    final regex = RegExp(r"(VoieAdmin|Dosage|Dose):\s*([\w\s]+)");
    final match = regex.firstMatch(text);
    return match?.group(2) ?? '';
  }

  /// Renvoie le nom de la forme pharmaceutique (ancien "durée")
  String _parseFormePharma(String text) {
    // On suppose qu'il y a un tag "FormePharma" ou "Durée|Duration" :
    final regex = RegExp(r"(FormePharma|Durée|Duration):\s*([\w\s]+)");
    final match = regex.firstMatch(text);
    return match?.group(2) ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _ocrError = null;
      });
    }
  }

  Future<void> _performOCR(String language) async {
    if (_selectedImage == null) {
      print("[DEBUG OCR] => Aucun fichier image sélectionné.");
      return;
    }

    print("[DEBUG OCR IMAGE PATH] => ${_selectedImage!.path}");

    setState(() => _isScanning = true);

    try {
      print("[DEBUG OCR] => Début de l'extraction OCR avec la langue: $language");

      final text = await FlutterTesseractOcr.extractText(
        _selectedImage!.path,
        language: language,
        args: {
          "psm": "3",
          "oem": "1",
          "preserve_interword_spaces": "1",
        },
      );

      print("[DEBUG OCR RESULT] => Texte extrait : $text");

      if (text.isEmpty) {
        throw Exception("Aucun texte extrait de l'image.");
      }

      // Parsing automatique
      final medication = _parseMedication(text);
      final voieAdmin = _parseVoieAdmin(text);
      final formePharma = _parseFormePharma(text);

      print(
          "[DEBUG OCR PARSE] => Médicament: $medication, VoieAdmin: $voieAdmin, FormePharma: $formePharma");

      setState(() => _isScanning = false);

      // Si tout est vide, on va vers la vérification manuelle
      if (medication.isEmpty && voieAdmin.isEmpty && formePharma.isEmpty) {
        context.go(
          '/doctor_review_ocr',
          extra: {
            'medication': '',
            'voieAdmin': '',
            'formePharma': '',
            'rawText': text,
          },
        );
      } else {
        // Sinon, on va directement à l'ajout de prescription
        context.go(
          '/doctor_add_prescription',
          extra: {
            'medication': medication,
            'voieAdmin': voieAdmin,
            'formePharma': formePharma,
          },
        );
      }
    } catch (e) {
      print("[DEBUG OCR ERROR] => Exception capturée : $e");
      setState(() {
        _isScanning = false;
        _ocrError = "Erreur OCR: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Scanner une Ordonnance")),
      drawer: _buildDoctorDrawer(context, authProvider),
      body: Center(
        child: _isScanning
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_ocrError != null)
                Text(_ocrError!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text("Importer depuis la Galerie"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text("Prendre une Photo"),
              ),
              const SizedBox(height: 20),
              if (_selectedImage != null) ...[
                const Text("Choisissez la langue du document :"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _performOCR("eng"),
                      child: const Text("Scanner (Anglais)"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _performOCR("fra"),
                      child: const Text("Scanner (Français)"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Drawer complet du Médecin
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
              context.go('/doctor_add_prescription');
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
