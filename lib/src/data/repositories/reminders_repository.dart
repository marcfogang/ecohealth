// lib/src/data/repositories/reminders_repository.dart

import 'package:hive/hive.dart';
import 'dart:math';

class RemindersRepository {
  final Box remindersBox;
  RemindersRepository({required this.remindersBox});

  Future<List<Map<String, dynamic>>> loadReminders(String patientId) async {
    final allValues = remindersBox.values;
    final results = allValues.where((r) => r['patientId'] == patientId);
    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> createReminder(Map<String, dynamic> reminderData) async {
    // Gen ID auto
    final lastId = remindersBox.isEmpty
        ? 0
        : remindersBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);
    final newId = lastId + 1;
    reminderData['id'] = newId;

    await remindersBox.put(newId, reminderData);
  }

  /// Mettre à jour un rappel (ex. si "needEmail = true" ou "alreadySentEmail" etc.)
  Future<void> updateReminder(int id, Map<String, dynamic> updatedData) async {
    // Fusionner avec l’existant
    final existing = remindersBox.get(id) ?? {};
    final merged = {...existing, ...updatedData};
    await remindersBox.put(id, merged);
  }
}
