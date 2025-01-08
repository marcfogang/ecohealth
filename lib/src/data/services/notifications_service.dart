// lib/src/data/services/notifications_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ✅ **Service de Notification Locale**
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  /// ✅ **Initialisation des Notifications**
  Future<void> initializeNotifications() async {
    // Initialisation Android
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('app_icon');
    // 'app_icon' doit exister dans /android/app/src/main/res/drawable/

    // Initialisation iOS
    const DarwinInitializationSettings iosInitSettings =
    DarwinInitializationSettings();

    // Paramètres globaux d'initialisation
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // ✅ Initialisation du Fuseau Horaire
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris')); // Ajustez si nécessaire
  }

  /// ✅ **Demander les permissions pour les notifications (iOS uniquement)**
  Future<void> requestNotificationPermissions() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (result == true) {
      debugPrint("✅ Permissions Notifications accordées");
    } else {
      debugPrint("❌ Permissions Notifications refusées");
    }
  }

  /// ✅ **Callback lors d'un clic sur une notification**
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint("🛎️ Notification cliquée avec payload : ${response.payload}");
  }

  /// ✅ **Afficher une Notification Immédiate**
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminder_channel_id',
      'Rappels',
      channelDescription: 'Canal pour les rappels',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// ✅ **Planifier une Notification**
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      debugPrint("⚠️ Date de notification déjà passée.");
      return;
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminder_channel_id',
      'Rappels Planifiés',
      channelDescription: 'Canal pour les rappels programmés',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZ(scheduledDate),
      platformDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      payload: payload,
    );
  }

  /// ✅ **Annuler une Notification**
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint("🔕 Notification $id annulée");
  }

  /// ✅ **Annuler Toutes les Notifications**
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("🔕 Toutes les notifications ont été annulées");
  }

  /// ✅ **Convertir DateTime en TZDateTime (Fuseau Horaire)**
  tz.TZDateTime _convertToTZ(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}

