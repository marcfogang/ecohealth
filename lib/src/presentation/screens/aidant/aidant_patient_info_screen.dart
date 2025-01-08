// lib/src/presentation/screens/aidant/aidant_patient_info_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/prescription_repository.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../state/auth_provider.dart';

class AidantPatientInfoScreen extends StatefulWidget {
  const AidantPatientInfoScreen({super.key});

  @override
  State<AidantPatientInfoScreen> createState() => _AidantPatientInfoScreenState();
}

class _AidantPatientInfoScreenState extends State<AidantPatientInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _patientIdController = TextEditingController();

  Map<String, dynamic> _patientData = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  /// Charger les données du patient
  Future<void> _loadPatientData() async {
    final patientId = _patientIdController.text.trim();
    if (patientId.isEmpty) {
      setState(() => _error = "Veuillez entrer un ID patient valide.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prescriptionRepo = context.read<PrescriptionRepository>();
      final stockRepo = context.read<StockRepository>();
      final appointmentRepo = context.read<AppointmentRepository>();

      final prescriptions = await prescriptionRepo.loadPrescriptionHistory(patientId);
      final stock = await stockRepo.getStockForPatient(patientId);
      final appointments = await appointmentRepo.loadAppointments(patientId);

      setState(() {
        _patientData = {
          'prescriptions': prescriptions,
          'stock': stock,
          'appointments': appointments,
        };
      });
    } catch (e) {
      setState(() {
        _error = "Erreur lors du chargement des données : $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Informations Patient"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Prescriptions"),
            Tab(text: "Stock"),
            Tab(text: "Rendez-vous"),
          ],
        ),
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
      drawer: _buildAidantDrawer(context, authProvider),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _patientIdController,
                    decoration: const InputDecoration(
                      labelText: "ID Patient",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadPatientData,
                  child: const Text("Charger"),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!)))
          else if (_patientData.isEmpty)
              const Expanded(child: Center(child: Text("Aucune donnée chargée.")))
            else
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPrescriptions(),
                    _buildStock(),
                    _buildAppointments(),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  /// Afficher les prescriptions
  Widget _buildPrescriptions() {
    final prescriptions = _patientData['prescriptions'] as List<Map<String, dynamic>>;
    return ListView.builder(
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return ListTile(
          title: Text("Médicament: ${prescription['name']}"),
          subtitle: Text("Dosage: ${prescription['dosage']}"),
        );
      },
    );
  }

  /// Afficher le stock
  Widget _buildStock() {
    final stock = _patientData['stock'] as List<Map<String, dynamic>>;
    return ListView.builder(
      itemCount: stock.length,
      itemBuilder: (context, index) {
        final item = stock[index];
        return ListTile(
          title: Text("Médicament: ${item['name']}"),
          subtitle: Text("Quantité: ${item['quantity']}"),
        );
      },
    );
  }

  /// Afficher les rendez-vous
  Widget _buildAppointments() {
    final appointments = _patientData['appointments'] as List<Map<String, dynamic>>;
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return ListTile(
          title: Text("Date: ${appointment['date']}"),
          subtitle: Text("Motif: ${appointment['motif']}"),
        );
      },
    );
  }

  /// 🛠️ **Drawer pour la navigation de l'Aidant**
  Drawer _buildAidantDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu Aidant',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu),
            title: const Text('Menu Aidant'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Informations Patient'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_patient_info');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_notifications');
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