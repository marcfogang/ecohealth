// lib/src/data/services/prescription_service.dart

import 'package:hive/hive.dart';

class PrescriptionService {
  final Box prescriptionBox;

  PrescriptionService({required this.prescriptionBox});

  Future<List<Map<String, dynamic>>> fetchPrescriptions(String patientId) async {
    // Filtrer par patientId
    final prescriptions = prescriptionBox.values.where((p) {
      if (p is Map && p['patientId'] == patientId) {
        return true;
      }
      return false;
    }).cast<Map<String,dynamic>>().toList();
    return prescriptions;
  }

  Future<bool> createPrescription(Map<String, dynamic> data) async {
    // Générer un id unique
    final newId = 'presc${prescriptionBox.length + 1}';
    await prescriptionBox.put(newId, {
      'id': newId,
      ...data,
    });
    return true;
  }
}
