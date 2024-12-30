// lib/src/data/services/appointment_service.dart

import 'package:hive/hive.dart';

class AppointmentService {
  final Box appointmentBox;

  AppointmentService({required this.appointmentBox});

  Future<List<Map<String, dynamic>>> fetchAppointments(String doctorId) async {
    final appointments = appointmentBox.values.where((appt) {
      if (appt is Map && appt['doctorId'] == doctorId) {
        return true;
      }
      return false;
    }).cast<Map<String,dynamic>>().toList();
    return appointments;
  }

  Future<bool> createAppointment(String doctorId, String patientId, String date) async {
    final newId = 'appt${appointmentBox.length + 1}';
    final newAppointment = {
      'id': newId,
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date,
    };
    await appointmentBox.put(newId, newAppointment);
    return true;
  }
}
