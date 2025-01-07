// lib/src/presentation/screens/patient/patient_stock_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../state/auth_provider.dart';

class PatientStockScreen extends StatefulWidget {
  const PatientStockScreen({super.key});

  @override
  State<PatientStockScreen> createState() => _PatientStockScreenState();
}

class _PatientStockScreenState extends State<PatientStockScreen> {
  late Future<List<Map<String, dynamic>>> _futureStock;

  @override
  void initState() {
    super.initState();
    final patientId = "patient123"; // ou context.read<AuthProvider>().userId
    final stockRepo = context.read<StockRepository>();
    _futureStock = stockRepo.getStockForPatient(patientId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Stock de Médicaments"),
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
        future: _futureStock,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final stockList = snapshot.data ?? [];
          if (stockList.isEmpty) {
            return const Center(child: Text("Aucun stock trouvé."));
          }

          return ListView.builder(
            itemCount: stockList.length,
            itemBuilder: (context, index) {
              final item = stockList[index];
              final medName = item['name'] ?? 'Médicament inconnu';
              final currentStock = item['quantity'] ?? 0;
              final medId = item['medId'];

              return ListTile(
                title: Text(medName),
                subtitle: Text("Stock actuel : $currentStock"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton pour décrémenter
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateStock(medId, currentStock - 1),
                    ),
                    // Bouton pour incrémenter
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateStock(medId, currentStock + 1),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateStock(String medId, int newQuantity) async {
    final stockRepo = context.read<StockRepository>();
    // Mise à jour locale (Hive) pour l'instant
    await stockRepo.updateStock(medId, newQuantity);

    // Rafraîchir l’écran
    setState(() {
      final patientId = "patient123";
      _futureStock = stockRepo.getStockForPatient(patientId);
    });

    // Plus tard, on enverra la MAJ au backend quand il sera prêt
    // ex: stockRepo.syncStockWithBackend(medId, newQuantity);
  }

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
