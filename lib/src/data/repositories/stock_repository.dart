// lib/src/data/repositories/stock_repository.dart

import 'package:hive/hive.dart';

class StockRepository {
  // Suppose usage de Hive en local
  Future<List<Map<String, dynamic>>> getStockForPatient(String patientId) async {
    // Retrouver la box, par ex.:
    // var box = Hive.box('stockBox');
    // Filtrer les items dont 'patientId' correspond
    // Retourner une liste de Map { 'medId': ..., 'name': ..., 'quantity': ... }
    throw UnimplementedError('À implémenter');
  }

  Future<void> updateStock(String medId, int newQuantity) async {
    // Mise à jour dans Hive en local
    // ex:
    // var box = Hive.box('stockBox');
    // await box.put(medId, {'quantity': newQuantity, ...});
    throw UnimplementedError('À implémenter');
  }
}
