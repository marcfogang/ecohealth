// lib/src/data/repositories/appointment_repository.dart

import 'package:hive/hive.dart';
import '../services/appointment_service.dart';

/// Un seul repository pour gérer
/// - la logique docteur (API)
/// - la logique patient (local Hive)
class AppointmentRepository {
  final AppointmentService appointmentService;
  final Box appointmentBox;

  AppointmentRepository({
    required this.appointmentService,
    required this.appointmentBox,
  });

  // ================== Docteur ================== //
  /// Docteur : Récupère les RDV via l’API
  Future<List<Map<String, dynamic>>> loadAppointmentsDoctor(String doctorId) async {
    return await appointmentService.fetchAppointments(doctorId);
  }

  /// Docteur : Crée un RDV via l’API
  Future<bool> addAppointmentDoctor(String doctorId, String patientId, String date) async {
    return await appointmentService.createAppointment(doctorId, patientId, date);
  }

  // ================== Patient ================== //
  /// Patient : Charge les rendez-vous localement (Hive)
  Future<List<Map<String, dynamic>>> loadAppointments(String patientId) async {
    // Filtrage local
    final allValues = appointmentBox.values;
    final results = allValues.where((rdv) => rdv['patientId'] == patientId);
    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Patient : Crée un RDV localement
  Future<void> createAppointment(Map<String, dynamic> rdvData) async {
    final lastId = appointmentBox.isEmpty
        ? 0
        : appointmentBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);
    final newId = lastId + 1;

    rdvData['id'] = newId;
    await appointmentBox.put(newId, rdvData);

    // Plus tard : call appointmentService.createAppointment(...)
    // pour synchro backend
  }
}
