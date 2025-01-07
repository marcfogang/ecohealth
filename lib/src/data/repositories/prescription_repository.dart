// lib/src/data/repositories/prescription_repository.dart

import 'package:hive/hive.dart';
import '../services/prescription_service.dart';

class PrescriptionRepository {
  final PrescriptionService prescriptionService;
  final Box prescriptionBox;

  PrescriptionRepository({
    required this.prescriptionService,
    required this.prescriptionBox,
  });

  Future<void> deletePrescription(int id) async {
    try {
      await prescriptionBox.delete(id);
      print("Prescription supprimée avec succès: ID $id");
    } catch (e) {
      print("Erreur lors de la suppression de la prescription: $e");
    }
  }
  Future<bool> addPrescription(String patientId, Map<String, dynamic> prescriptionData) async {
    try {
      // 🔄 Génération d'un ID incrémental
      final lastId = prescriptionBox.isEmpty ? 0 : prescriptionBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);
      final newId = lastId + 1;

      prescriptionData['id'] = newId; // ID Incrémental
      prescriptionData['patientId'] = patientId;
      prescriptionData['createdAt'] = DateTime.now().toIso8601String();

      await prescriptionBox.put(newId, prescriptionData);
      return true;
    } catch (e) {
      print("Erreur lors de l'ajout de la prescription: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> loadPrescriptionHistory(String patientId) async {
    try {
      final prescriptions = prescriptionBox.values
          .where((p) => p['patientId'] == patientId)
          .cast<Map<String, dynamic>>()
          .toList();
      return prescriptions;
    } catch (e) {
      print("Erreur lors du chargement de l'historique des prescriptions: $e");
      return [];
    }
  }
}

