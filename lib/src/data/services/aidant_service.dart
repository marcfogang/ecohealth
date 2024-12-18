// lib/src/data/services/aidant_service.dart

import 'dart:async';

class AidantService {
  final List<Map<String, dynamic>> _fakeAidants = [];

  Future<bool> addAidant(String patientId, Map<String, dynamic> aidantData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fakeAidants.add({
      'patientId': patientId,
      'name': aidantData['name'],
      'email': aidantData['email'],
    });
    return true;
  }

  Future<List<Map<String, dynamic>>> fetchAidants(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _fakeAidants.where((a) => a['patientId'] == patientId).toList();
  }
}
