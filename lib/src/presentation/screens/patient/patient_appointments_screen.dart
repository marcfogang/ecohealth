// lib/src/presentation/screens/patient/patient_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../state/auth_provider.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  late Future<List<Map<String, dynamic>>> _futureAppointments;

  @override
  void initState() {
    super.initState();
    final patientId = "patient123"; // ou context.read<AuthProvider>().userId
    final appointmentRepo = context.read<AppointmentRepository>();

    // On charge la liste de rendez-vous en local (Hive) pour l’instant
    _futureAppointments = appointmentRepo.loadAppointments(patientId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Rendez-vous"),
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
        future: _futureAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) {
            return const Center(child: Text("Aucun rendez-vous trouvé."));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final rdv = appointments[index];
              final rdvId = rdv['id'];
              final date = rdv['date'] ?? 'Date inconnue';
              final doctor = rdv['doctorName'] ?? 'Médecin inconnu';

              return ListTile(
                title: Text("RDV #$rdvId - Dr. $doctor"),
                subtitle: Text("Date : $date"),
                onTap: () => _showAppointmentDetails(rdv),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _simulateReserveRDV,
        tooltip: 'Réserver un RDV',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Montre un simple pop-up avec les détails du RDV
  void _showAppointmentDetails(Map<String, dynamic> rdv) {
    showDialog(
      context: context,
      builder: (ctx) {
        final date = rdv['date'] ?? 'Date inconnue';
        final doctor = rdv['doctorName'] ?? 'Médecin inconnu';
        final motif = rdv['motif'] ?? 'N/A';

        return AlertDialog(
          title: Text("Détails Rendez-vous #${rdv['id']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Date : $date"),
              Text("Médecin : $doctor"),
              Text("Motif : $motif"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Fermer"),
            )
          ],
        );
      },
    );
  }

  /// Simule la création d'un nouveau RDV
  Future<void> _simulateReserveRDV() async {
    // Ex: date = "2023-10-10 15:00", doctorName = "Dr House"
    final newRDV = {
      'patientId': 'patient123',
      'doctorName': 'Dr House',
      'date': '2023-10-10 15:00',
      'motif': 'Consultation générale',
    };

    final appointmentRepo = context.read<AppointmentRepository>();

    // On simule l'appel à appointment_service.createAppointment
    // stocké localement via appointmentRepo
    await appointmentRepo.createAppointment(newRDV);

    // Rafraîchir la liste
    setState(() {
      final patientId = "patient123";
      _futureAppointments = appointmentRepo.loadAppointments(patientId);
    });
  }

  /// Drawer identique Patient
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
