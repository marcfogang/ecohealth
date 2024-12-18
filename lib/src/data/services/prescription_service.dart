// lib/src/data/services/prescription_service.dart

import 'dart:async';

class PrescriptionService {
  // Simulez une liste de prescriptions factices
  // Chaque prescription peut être un Map avec {id, patientId, medication(s), date, etc.}
  final List<Map<String, dynamic>> _fakePrescriptions = [
    {
      'id': 'presc1',
      'patientId': 'patient123',
      'medications': [
        {'name': 'Amoxicillin', 'dosage': '1g', 'duration': '7 days'}
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    },
    {
      'id': 'presc2',
      'patientId': 'patient123',
      'medications': [
        {'name': 'Ibuprofen', 'dosage': '400mg', 'duration': '3 days'}
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
  ];

  Future<List<Map<String, dynamic>>> fetchPrescriptions(String patientId) async {
    // Simule un délai
    await Future.delayed(const Duration(milliseconds: 500));
    // Retourne les prescriptions correspondant à ce patient
    return _fakePrescriptions.where((p) => p['patientId'] == patientId).toList();
  }

  Future<bool> createPrescription(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    // Ajoutez la prescription factice
    final newPrescription = {
      'id': 'presc${_fakePrescriptions.length + 1}',
      'patientId': data['patientId'],
      'medications': data['medications'],
      'createdAt': data['scannedAt'] ?? DateTime.now().toIso8601String(),
    };
    _fakePrescriptions.add(newPrescription);
    return true; // toujours succès pour l’instant
  }
}
