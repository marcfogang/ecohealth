// lib/src/data/repositories/notifications_repository.dart

import 'package:hive/hive.dart';

class NotificationsRepository {
  final Box notificationsBox;

  NotificationsRepository({required this.notificationsBox});

  /// Charger toutes les notifications
  Future<List<Map<String, dynamic>>> loadNotifications() async {
    final allNotifications = notificationsBox.values.toList();
    return allNotifications
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Ajouter une notification (Simulation)
  Future<void> addNotification(Map<String, dynamic> notificationData) async {
    final lastId = notificationsBox.isEmpty
        ? 0
        : notificationsBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);
    final newId = lastId + 1;

    notificationData['id'] = newId;
    notificationData['read'] = false;

    await notificationsBox.put(newId, notificationData);
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(int notificationId) async {
    final notification = notificationsBox.get(notificationId);
    if (notification != null) {
      notification['read'] = true;
      await notificationsBox.put(notificationId, notification);
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(int notificationId) async {
    await notificationsBox.delete(notificationId);
  }
}
