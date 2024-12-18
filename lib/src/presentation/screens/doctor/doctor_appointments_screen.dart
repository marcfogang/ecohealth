// lib/src/presentation/screens/doctor/doctor_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';
import '../../../data/repositories/appointment_repository.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = false;
  final _patientIdController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final appointmentRepository = context.read<AppointmentRepository>();
    setState(() => _isLoading = true);
    _appointments = await appointmentRepository.loadAppointments("doctor123");
    setState(() => _isLoading = false);
  }

  Future<void> _addAppointment() async {
    final appointmentRepository = context.read<AppointmentRepository>();
    final success = await appointmentRepository.addAppointment(
      "doctor123",
      _patientIdController.text.trim(),
      _dateController.text.trim(),
    );
    if (success) {
      _patientIdController.clear();
      _dateController.clear();
      await _loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Rendez-vous")),
      drawer: _buildDoctorDrawer(context, authProvider),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _patientIdController,
                        decoration: const InputDecoration(labelText: "Patient ID"),
                      ),
                      TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(labelText: "Date (YYYY-MM-DD HH:MM)"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _addAppointment,
                        child: const Text("Ajouter Rendez-vous"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appt = _appointments[index];
                      return ListTile(
                        title: Text("RDV ${appt['id']} avec patient ${appt['patientId']}"),
                        subtitle: Text("Date: ${appt['date']}"),
                      );
                    },
                  ),
                ),
              ],
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
