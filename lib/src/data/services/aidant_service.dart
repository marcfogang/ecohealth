// lib/src/data/services/aidant_service.dart

import 'package:hive/hive.dart';

class AidantService {
  final Box aidantBox;

  AidantService({required this.aidantBox});

  Future<bool> addAidant(String patientId, Map<String, dynamic> aidantData) async {
    // Générer un id unique pour l'aidant
    final newId = 'aidant${aidantBox.length + 1}';
    final newAidant = {
      'id': newId,
      'patientId': patientId,
      'name': aidantData['name'],
      'email': aidantData['email'],
    };
    await aidantBox.put(newId, newAidant);
    return true;
  }

  Future<List<Map<String, dynamic>>> fetchAidants(String patientId) async {
    final aidants = aidantBox.values.where((a) {
      if (a is Map && a['patientId'] == patientId) {
        return true;
      }
      return false;
    }).cast<Map<String,dynamic>>().toList();
    return aidants;
  }
}
