// lib/src/data/repositories/appointment_repository.dart

import 'package:hive/hive.dart';
import '../services/appointment_service.dart';

class AppointmentRepository {
  final AppointmentService appointmentService;
  final Box appointmentBox;

  AppointmentRepository({required this.appointmentService, required this.appointmentBox});

  Future<List<Map<String, dynamic>>> loadAppointments(String doctorId) async {
    return await appointmentService.fetchAppointments(doctorId);
  }

  Future<bool> addAppointment(String doctorId, String patientId, String date) async {
    return await appointmentService.createAppointment(doctorId, patientId, date);
  }
}
