// lib/src/presentation/screens/patient/patient_reminders_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/reminders_repository.dart';
import '../../../data/services/notifications_service.dart';
import '../../state/auth_provider.dart';
import 'package:intl/intl.dart';

class PatientRemindersScreen extends StatefulWidget {
  const PatientRemindersScreen({super.key});

  @override
  State<PatientRemindersScreen> createState() => _PatientRemindersScreenState();
}

class _PatientRemindersScreenState extends State<PatientRemindersScreen> {
  late Future<List<Map<String, dynamic>>> _futureReminders;

  // Formulaire
  final _titleController = TextEditingController();
  DateTime? _selectedDateTime;

  bool _isLoading = false;
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final patientId = 'patient123'; // ex: context.read<AuthProvider>().userId
    final remindersRepo = context.read<RemindersRepository>();
    setState(() => _isLoading = true);
    _reminders = await remindersRepo.loadReminders(patientId);
    setState(() => _isLoading = false);
  }

  Future<void> _pickDateTime() async {
    // Choix de la date
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (pickedDate == null) return;

    // Choix de l'heure
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (pickedTime == null) return;

    final finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      _selectedDateTime = finalDateTime;
    });
  }

  Future<void> _addReminder() async {
    if (_titleController.text.trim().isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir un titre et une date.")),
      );
      return;
    }
    final title = _titleController.text.trim();
    final dateTime = _selectedDateTime!;

    // 1) Stocker en local
    final remindersRepo = context.read<RemindersRepository>();
    final newReminder = {
      'patientId': 'patient123',
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'needEmail': true, // on simule qu'on veut un email
    };
    await remindersRepo.createReminder(newReminder);

    // 2) Planifier la notification
    final notiService = NotificationService();
    final idRandom = DateTime.now().millisecondsSinceEpoch % 100000;
    await notiService.scheduleNotification(
      id: idRandom,
      title: "Rappel : $title",
      body: "C’est le moment de $title",
      scheduledDate: dateTime,
    );

    // 3) Optionnel : plus tard, on enverra “needEmail: true” au backend => API Bravo
    // (ici, on se limite à le stocker localement)

    // Nettoyage
    _titleController.clear();
    _selectedDateTime = null;

    // Reload
    await _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Rappels"),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Formulaire d'ajout de rappel
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration:
                  const InputDecoration(labelText: "Titre du rappel"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickDateTime,
                      child: const Text("Choisir date/heure"),
                    ),
                    const SizedBox(width: 10),
                    _selectedDateTime == null
                        ? const Text("Aucune date choisie")
                        : Text(DateFormat('yyyy-MM-dd HH:mm')
                        .format(_selectedDateTime!)),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addReminder,
                  child: const Text("Créer Rappel"),
                ),
              ],
            ),
          ),
          // Liste des rappels
          Expanded(
            child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final r = _reminders[index];
                final dateTime = r['dateTime'] ?? 'N/A';
                final title = r['title'] ?? 'Sans titre';

                return ListTile(
                  title: Text(title),
                  subtitle: Text("Prévu le : $dateTime"),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// Drawer identique à celui du PatientHomeScreen,
  /// permettant la navigation vers les différents écrans Patient.
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
