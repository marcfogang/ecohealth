// lib/src/presentation/screens/doctor/doctor_manage_aidants_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';
import '../../../data/repositories/aidant_repository.dart';

class DoctorManageAidantsScreen extends StatefulWidget {
  const DoctorManageAidantsScreen({super.key});

  @override
  State<DoctorManageAidantsScreen> createState() => _DoctorManageAidantsScreenState();
}

class _DoctorManageAidantsScreenState extends State<DoctorManageAidantsScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  List<Map<String, dynamic>> _aidants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAidants();
  }

  Future<void> _loadAidants() async {
    final aidantRepository = context.read<AidantRepository>();
    setState(() => _isLoading = true);
    _aidants = await aidantRepository.loadAidants("patient123");
    setState(() => _isLoading = false);
  }

  Future<void> _addAidant() async {
    final aidantRepository = context.read<AidantRepository>();
    final success = await aidantRepository.addAidant("patient123", {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
    });
    if (success) {
      _nameController.clear();
      _emailController.clear();
      await _loadAidants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Aidants")),
      drawer: _buildDoctorDrawer(context, authProvider),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Nom de l'aidant"),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email de l'aidant"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addAidant,
                    child: const Text("Ajouter Aidant"),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _aidants.length,
                      itemBuilder: (context, index) {
                        final a = _aidants[index];
                        return ListTile(
                          title: Text(a['name']),
                          subtitle: Text(a['email']),
                        );
                      },
                    ),
                  ),
                ],
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
