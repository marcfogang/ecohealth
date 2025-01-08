// lib/src/presentation/screens/aidant/aidant_notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../state/auth_provider.dart';

class AidantNotificationsScreen extends StatefulWidget {
  const AidantNotificationsScreen({super.key});

  @override
  State<AidantNotificationsScreen> createState() =>
      _AidantNotificationsScreenState();
}

class _AidantNotificationsScreenState extends State<AidantNotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// Charger les notifications depuis le repository
  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notificationsRepo = context.read<NotificationsRepository>();
      final fetchedNotifications = await notificationsRepo.loadNotifications();
      setState(() {
        _notifications = fetchedNotifications;
      });
    } catch (e) {
      print("Erreur de chargement des notifications : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Marquer une notification comme lue
  Future<void> _markAsRead(int notificationId) async {
    final notificationsRepo = context.read<NotificationsRepository>();
    await notificationsRepo.markAsRead(notificationId);
    await _loadNotifications();
  }

  /// Supprimer une notification
  Future<void> _deleteNotification(int notificationId) async {
    final notificationsRepo = context.read<NotificationsRepository>();
    await notificationsRepo.deleteNotification(notificationId);
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications Aidant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _loadNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: _buildAidantDrawer(context, authProvider),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text("Aucune notification reçue."))
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification['title'] ?? 'Notification'),
            subtitle: Text(notification['message'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!(notification['read'] ?? false))
                  IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    tooltip: 'Marquer comme lue',
                    onPressed: () =>
                        _markAsRead(notification['id']),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Supprimer',
                  onPressed: () =>
                      _deleteNotification(notification['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🛠️ **Drawer pour la navigation de l'Aidant**
  Drawer _buildAidantDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu Aidant',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu),
            title: const Text('Menu Aidant'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Informations Patient'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_patient_info');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aidant_notifications');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}