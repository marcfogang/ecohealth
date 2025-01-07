// lib/src/presentation/screens/doctor/doctor_add_prescription_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
// Import de la lib debounce_throttle (v2.0.0)
import 'package:debounce_throttle/debounce_throttle.dart';

import '../../../data/repositories/prescription_repository.dart';
import '../../state/auth_provider.dart';
import '../../../data/services/medication_api_service.dart';
import '../../../data/models/medication_details_15.dart';

/// Représentation basique du médicament (défini dans medication_api_service.dart)
/// class MedicationBasicInfo { ... }

class DoctorAddPrescriptionScreen extends StatefulWidget {
  final String medication;
  final String voieAdmin;   // ancien "dosage"
  final String formePharma; // ancien "duration"

  const DoctorAddPrescriptionScreen({
    super.key,
    this.medication = '',
    this.voieAdmin = '',
    this.formePharma = '',
  });

  @override
  State<DoctorAddPrescriptionScreen> createState() =>
      _DoctorAddPrescriptionScreenState();
}

class _DoctorAddPrescriptionScreenState
    extends State<DoctorAddPrescriptionScreen> {
  // Contrôleurs texte
  late TextEditingController _medicationController;
  late TextEditingController _voieAdminController;    // ex- _dosageController
  late TextEditingController _formePharmaController;  // ex- _durationController

  bool _isSaving = false;
  String? _message;

  // Suggestions de médicaments (via l’API)
  List<MedicationBasicInfo> _suggestions = [];
  bool _isSearching = false;

  // Debouncer (v2.0.0)
  late Debouncer<String> _debouncer;

  // Retenir le drugCode choisi pour l’enregistrement
  String? _selectedDrugCode;

  @override
  void initState() {
    super.initState();

    // Initialisation contrôleurs
    _medicationController = TextEditingController(text: widget.medication);
    _voieAdminController = TextEditingController(text: widget.voieAdmin);
    _formePharmaController = TextEditingController(text: widget.formePharma);

    // Instanciation du Debouncer
    _debouncer = Debouncer<String>(
      const Duration(milliseconds: 500),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _searchMedication(value);
        } else {
          if (mounted) {
            setState(() => _suggestions.clear());
          }
        }
      },
      initialValue: '',
    );

    // À chaque frappe dans _medicationController, on assigne la valeur au debouncer
    _medicationController.addListener(() {
      _debouncer.value = _medicationController.text;
    });
  }

  /// Requête à l'API pour chercher un médicament
  Future<void> _searchMedication(String query) async {
    setState(() => _isSearching = true);
    try {
      final medicationApi = context.read<MedicationApiService>();
      final results = await medicationApi.searchMedications(query, lang: 'fr');
      setState(() => _suggestions = results);
    } catch (e) {
      print('Erreur recherche médicament : $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// Quand on sélectionne un médicament dans la liste
  /// 1) Remplit le champ "médicament"
  /// 2) Va chercher plus de détails (MedicationDetails15)
  void _selectMedication(MedicationBasicInfo med) async {
    // Stocker le drug_code pour l’enregistrement
    _selectedDrugCode = med.drugCode;

    // Remplit le champ "médicament"
    _medicationController.text = med.brandName;

    try {
      final api = context.read<MedicationApiService>();
      final details = await api.fetchMedicationDetails(med.drugCode, lang: 'fr');

      // Auto-remplir "Nom de la voie administrative" et "Nom de la forme pharmaceutique"
      // Selon votre logique : on prend details.nomDeLaVoieAdministrative et details.nomFormePharmaceutique
      _voieAdminController.text = details.nomDeLaVoieAdministrative;
      _formePharmaController.text = details.nomFormePharmaceutique;

    } catch (e) {
      print("Impossible de charger details pour auto-fill voie/forme : $e");
    }

    setState(() => _suggestions.clear());
  }

  /// Sauvegarde la prescription => On stocke drug_code
  Future<void> _savePrescription() async {
    setState(() {
      _isSaving = true;
      _message = null;
    });
    final prescriptionRepo = context.read<PrescriptionRepository>();

    // Prépare les données à sauvegarder dans Hive
    final dataToSave = <String, dynamic>{
      'patientId': 'patient123',
      'medications': [
        {
          'name': _medicationController.text.trim(),
          // On enregistre sous "voie_administrative" et "forme_pharmaceutique" par ex.
          'voie_administrative': _voieAdminController.text.trim(),
          'forme_pharmaceutique': _formePharmaController.text.trim(),
        },
      ],
      'scannedAt': DateTime.now().toIso8601String(),
    };

    // Si on a un drug_code, on le stocke
    if (_selectedDrugCode != null) {
      dataToSave['drug_code'] = _selectedDrugCode;
    }

    final success = await prescriptionRepo.addPrescription('patient123', dataToSave);

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
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.green)),

            // -- Champ : Nom du médicament
            TextField(
              controller: _medicationController,
              decoration: const InputDecoration(labelText: "Nom du Médicament"),
            ),

            // Indicateur de chargement pendant la recherche
            if (_isSearching) const LinearProgressIndicator(),

            // Liste de suggestions
            if (_suggestions.isNotEmpty)
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final med = _suggestions[index];
                    return ListTile(
                      title: Text(med.brandName),
                      subtitle: Text("DIN: ${med.din}"),
                      onTap: () => _selectMedication(med),
                    );
                  },
                ),
              ),

            // -- Champ : Nom de la voie administrative
            TextField(
              controller: _voieAdminController,
              decoration: const InputDecoration(
                labelText: "Nom de la voie administrative",
              ),
            ),

            // -- Champ : Nom de la forme pharmaceutique
            TextField(
              controller: _formePharmaController,
              decoration: const InputDecoration(
                labelText: "Nom de la forme pharmaceutique",
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePrescription,
              child: const Text("Valider la Prescription"),
            ),
          ],
        ),
      ),
    );
  }

  // Drawer "inchangé"
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
