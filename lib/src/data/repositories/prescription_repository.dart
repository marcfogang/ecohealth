// lib/src/data/repositories/prescription_repository.dart

import '../services/prescription_service.dart';

class PrescriptionRepository {
  final PrescriptionService prescriptionService;

  PrescriptionRepository({required this.prescriptionService});

  Future<List<Map<String, dynamic>>> loadPrescriptionHistory(String patientId, {int lastMonths = 6}) async {
    final prescriptions = await prescriptionService.fetchPrescriptions(patientId);
    final cutoffDate = DateTime.now().subtract(Duration(days: lastMonths * 30)); // approx
    return prescriptions.where((p) {
      final createdAt = DateTime.parse(p['createdAt']);
      return createdAt.isAfter(cutoffDate);
    }).toList();
  }

  Future<bool> addPrescription(String patientId, Map<String, dynamic> prescriptionData) async {
    // Assurez-vous que prescriptionData contient le patientId
    final data = {
      'patientId': patientId,
      ...prescriptionData,
    };
    return await prescriptionService.createPrescription(data);
  }
}
