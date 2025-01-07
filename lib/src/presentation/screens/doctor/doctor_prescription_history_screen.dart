// lib/src/presentation/screens/doctor/doctor_prescription_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import '../../../data/repositories/prescription_repository.dart';
import '../../../data/services/medication_api_service.dart';
import '../../../data/models/medication_details_15.dart';

class DoctorPrescriptionHistoryScreen extends StatefulWidget {
  const DoctorPrescriptionHistoryScreen({super.key});

  @override
  State<DoctorPrescriptionHistoryScreen> createState() =>
      _DoctorPrescriptionHistoryScreenState();
}

class _DoctorPrescriptionHistoryScreenState
    extends State<DoctorPrescriptionHistoryScreen> {
  final Set<int> _selectedPrescriptions = {};
  bool _isDeleting = false;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedPrescriptions.contains(id)) {
        _selectedPrescriptions.remove(id);
      } else {
        _selectedPrescriptions.add(id);
      }
    });
  }

  Future<void> _deleteSelectedPrescriptions() async {
    if (_selectedPrescriptions.isEmpty) return;

    final prescriptionRepository = context.read<PrescriptionRepository>();
    setState(() => _isDeleting = true);

    for (var id in _selectedPrescriptions) {
      await prescriptionRepository.deletePrescription(id);
    }

    setState(() {
      _isDeleting = false;
      _selectedPrescriptions.clear();
    });
    setState(() {});
  }

  /// Popup basique
  void _showBasicDetails(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Prescription #${p['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💊 Médicament: ${p['medications'][0]['name']}'),
            Text('💉 Dosage: ${p['medications'][0]['dosage']}'),
            Text('📅 Durée: ${p['medications'][0]['duration']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Va chercher les 15 champs
  Future<void> _fetchAndShowAllDetails(String drugCode) async {
    try {
      final api = context.read<MedicationApiService>();
      final details = await api.fetchMedicationDetails(drugCode);
      _showFullMedicationDetails(details);
    } catch (e) {
      print("Erreur fetchMedicationDetails: $e");
    }
  }

  /// Affiche la popup avec 15 champs
  void _showFullMedicationDetails(MedicationDetails15 d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Infos complètes du Médicament #${d.codeMedicament}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🐾 nom_espèce_vétérinaire : ${d.nomEspeceVeterinaire}"),
              Text("⏳ date_d'expiration : ${d.dateExpiration}"),
              Text("📅 historique_date : ${d.historiqueDate}"),
              Text("🏥 nom_du_programme : ${d.nomDuProgramme}"),
              Text("💉 nom_de_la_voie_administrative : ${d.nomDeLaVoieAdministrative}"),
              Text("📦 type_de_paquet : ${d.typeDePaquet}"),
              Text("📄 informations_sur_le_produit : ${d.informationsSurLeProduit}"),
              Text("🔢 CUP : ${d.cup}"),
              Text("💊 nom_forme_pharmaceutique : ${d.nomFormePharmaceutique}"),
              Text("🏷️ nom_de_marque : ${d.nomDeMarque}"),
              Text("🏷️ nom_de_classe : ${d.nomDeClasse}"),
              Text("📝 descripteur : ${d.descripteur}"),
              Text("💊 code_médicament : ${d.codeMedicament}"),
              Text("🔢 numéro_d'identification_du_médicament : ${d.numeroIdentificationMedicament}"),
              Text("🔢 nombre_de_ais : ${d.nombreDeAis}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  /// Callback principal quand on clique sur la prescription
  void _showPrescriptionDetails(Map<String, dynamic> prescription) {
    // Si on a stocké un 'drug_code', on peut fetch l’API
    final drugCode = prescription['drug_code'] as String?;
    if (drugCode != null && drugCode.isNotEmpty) {
      // On va chercher les 15 champs
      _fetchAndShowAllDetails(drugCode);
    } else {
      // Sinon, on affiche juste la popup basique
      _showBasicDetails(prescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final prescriptionRepository = context.read<PrescriptionRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Prescriptions"),
        actions: [
          if (_selectedPrescriptions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Supprimer les prescriptions sélectionnées",
              onPressed: _deleteSelectedPrescriptions,
            ),
        ],
      ),
      drawer: _buildDoctorDrawer(context, authProvider),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: prescriptionRepository.loadPrescriptionHistory("patient123"),
        builder: (context, snapshot) {
          if (_isDeleting) {
            return const Center(child: CircularProgressIndicator());
          }
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
              final isSelected = _selectedPrescriptions.contains(p['id']);
              return ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(p['id']),
                ),
                title: Text("Prescription #${p['id']}"),
                subtitle: Text("Date : ${p['createdAt']}"),
                trailing: const Icon(Icons.info_outline),
                onTap: () => _showPrescriptionDetails(p),
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
            child: Text(
              'Menu Médecin',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
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
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historique des Prescriptions'),
            onTap: () => context.go('/doctor_prescription_history'),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Gestion des Aidants'),
            onTap: () => context.go('/doctor_manage_aidants'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Gestion des Rendez-vous'),
            onTap: () => context.go('/doctor_appointments'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
