// lib/src/presentation/screens/doctor/doctor_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';
import '../../../data/repositories/appointment_repository.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = false;
  final _patientIdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  /// On charge la liste de RDV côté docteur
  Future<void> _loadAppointments() async {
    final appointmentRepository = context.read<AppointmentRepository>();
    setState(() => _isLoading = true);

    // ⚠️ ICI on utilise loadAppointmentsDoctor
    _appointments = await appointmentRepository.loadAppointmentsDoctor("doctor123");

    setState(() => _isLoading = false);
  }

  /// Choisir la date via un datePicker
  Future<void> _chooseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Ajouter RDV côté docteur
  Future<void> _addAppointment() async {
    if (_selectedDate == null || _patientIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez saisir un patientId et choisir une date.")),
      );
      return;
    }
    final appointmentRepository = context.read<AppointmentRepository>();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);

    // ⚠️ ICI on utilise addAppointmentDoctor
    final success = await appointmentRepository.addAppointmentDoctor(
      "doctor123",
      _patientIdController.text.trim(),
      dateStr,
    );

    if (success) {
      _patientIdController.clear();
      _selectedDate = null;
      await _loadAppointments(); // Rafraîchir la liste
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _chooseDate,
                      child: const Text("Choisir la date"),
                    ),
                    const SizedBox(width: 10),
                    _selectedDate == null
                        ? const Text("Aucune date choisie")
                        : Text(DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                  ],
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
            child: Text('Menu Médecin',
                style: TextStyle(color: Colors.white, fontSize: 20)),
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
