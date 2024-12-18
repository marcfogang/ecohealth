// lib/src/data/repositories/aidant_repository.dart

import '../services/aidant_service.dart';

class AidantRepository {
  final AidantService aidantService;

  AidantRepository({required this.aidantService});

  Future<List<Map<String, dynamic>>> loadAidants(String patientId) async {
    return await aidantService.fetchAidants(patientId);
  }

  Future<bool> addAidant(String patientId, Map<String, dynamic> aidantData) async {
    return await aidantService.addAidant(patientId, aidantData);
  }
}
