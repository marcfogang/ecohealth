import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Optionnel, si vous avez besoin de WidgetsBindingObserver, etc.
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider({required this.authRepository}) {
    _checkAuthStatus();
  }

  /// Vérifie si un token est présent au démarrage de l’app.
  Future<void> _checkAuthStatus() async {
    final token = await authRepository.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }

  /// Tente de se connecter avec email/password.
  /// Retourne true si succès, false sinon.
  Future<bool> login(String email, String password) async {
    final success = await authRepository.login(email, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  /// Tente de s’inscrire.
  /// Retourne true si succès, false sinon.
  Future<bool> signup(String email, String password) async {
    final success = await authRepository.signup(email, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  /// Déconnecte l’utilisateur.
  Future<void> logout() async {
    await authRepository.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Tente de rafraîchir le token (optionnel, si nécessaire).
  /// Peut être appelé lorsqu’on obtient un 401 (non géré ici, mais dans l’intercepteur).
  Future<bool> refresh() async {
    final refreshed = await authRepository.refreshToken();
    if (!refreshed) {
      // Si le refresh échoue, on déconnecte l’utilisateur.
      await logout();
    }
    return refreshed;
  }
}
