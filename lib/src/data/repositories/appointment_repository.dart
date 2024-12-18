// lib/src/data/repositories/appointment_repository.dart

import '../services/appointment_service.dart';

class AppointmentRepository {
  final AppointmentService appointmentService;

  AppointmentRepository({required this.appointmentService});

  Future<List<Map<String, dynamic>>> loadAppointments(String doctorId) async {
    return await appointmentService.fetchAppointments(doctorId);
  }

  Future<bool> addAppointment(String doctorId, String patientId, String date) async {
    return await appointmentService.createAppointment(doctorId, patientId, date);
  }
}
