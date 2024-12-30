// lib/src/data/repositories/aidant_repository.dart

import 'package:hive/hive.dart';
import '../services/aidant_service.dart';

class AidantRepository {
  final AidantService aidantService;
  final Box aidantBox;

  AidantRepository({required this.aidantService, required this.aidantBox});

  Future<List<Map<String, dynamic>>> loadAidants(String patientId) async {
    return await aidantService.fetchAidants(patientId);
  }

  Future<bool> addAidant(String patientId, Map<String, dynamic> aidantData) async {
    return await aidantService.addAidant(patientId, aidantData);
  }
}
