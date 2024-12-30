// lib/src/data/repositories/auth_repository.dart

import 'package:hive/hive.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;
  final Box userBox;

  AuthRepository({required this.authService, required this.userBox});

  Future<bool> login(String email, String password, String role) async {
    try {
      final token = await authService.login(email, password, role);
      final userEntry = userBox.values.firstWhere(
        (u) => u is Map && u['email'] == email && u['role'] == role,
        orElse: () => null,
      );
      if (userEntry != null) {
        await userBox.put('currentUser', userEntry);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String email, String password, String role) async {
    try {
      final token = await authService.signup(email, password, role);
      // On récupère l'utilisateur créé
      final newUser = userBox.get(email);
      // Pas de redirection automatique après signup, juste stocker l'user si besoin
      // On peut stocker l'utilisateur actuel ou non, ici on va juste ne rien faire.
      return newUser != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await userBox.delete('currentUser');
  }

  Future<String?> getToken() async {
    final currentUser = userBox.get('currentUser');
    return currentUser != null ? currentUser['token'] : null;
  }

  Future<bool> refreshToken() async {
    final token = await getToken();
    if (token == null) return false;
    try {
      final newToken = await authService.refreshToken(token);
      final currentUser = userBox.get('currentUser');
      if (currentUser != null) {
        currentUser['token'] = newToken;
        await userBox.put('currentUser', currentUser);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    return userBox.get('currentUser');
  }
}
