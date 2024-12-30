// lib/src/data/repositories/prescription_repository.dart

import 'package:hive/hive.dart';
import '../services/prescription_service.dart';

class PrescriptionRepository {
  final PrescriptionService prescriptionService;
  final Box prescriptionBox;

  PrescriptionRepository({required this.prescriptionService, required this.prescriptionBox});

  Future<List<Map<String, dynamic>>> loadPrescriptionHistory(String patientId, {int lastMonths = 6}) async {
    final prescriptions = await prescriptionService.fetchPrescriptions(patientId);
    final cutoffDate = DateTime.now().subtract(Duration(days: lastMonths * 30));
    return prescriptions.where((p) {
      final createdAt = DateTime.tryParse(p['scannedAt'] ?? p['createdAt'] ?? '');
      if (createdAt == null) return false;
      return createdAt.isAfter(cutoffDate);
    }).toList();
  }

  Future<bool> addPrescription(String patientId, Map<String, dynamic> prescriptionData) async {
    return await prescriptionService.createPrescription(prescriptionData);
  }
}
