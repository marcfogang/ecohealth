// lib/src/data/services/appointment_service.dart

import 'dart:async';

class AppointmentService {
  final List<Map<String, dynamic>> _fakeAppointments = [
    {
      'id': 'appt1',
      'doctorId': 'doctor123',
      'patientId': 'patient123',
      'date': DateTime.now().add(const Duration(days:1)).toIso8601String()
    }
  ];

  Future<List<Map<String, dynamic>>> fetchAppointments(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _fakeAppointments.where((a) => a['doctorId'] == doctorId).toList();
  }

  Future<bool> createAppointment(String doctorId, String patientId, String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fakeAppointments.add({
      'id': 'appt${_fakeAppointments.length + 1}',
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date,
    });
    return true;
  }
}
