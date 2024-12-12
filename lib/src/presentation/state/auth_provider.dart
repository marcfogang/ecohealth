import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Optionnel, si vous avez besoin de WidgetsBindingObserver, etc.
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _role; 
  String? get role => _role;

  AuthProvider({required this.authRepository}) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await authRepository.getToken();
    _isAuthenticated = token != null;
    // Si on veut simuler un rôle même lorsqu'on est déjà authentifié
    // (par exemple si l’utilisateur avait déjà un token), on peut mettre un rôle par défaut :
    // _role = _isAuthenticated ? 'patient' : null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final success = await authRepository.login(email, password);
    if (success) {
      _isAuthenticated = true;
      // On assigne un rôle factice, en attendant le backend
      // Par exemple, on décide arbitrairement que tous les logins actuels sont des "patients"
      _role = 'doctor';
      notifyListeners();
    }
    return success;
  }

  Future<bool> signup(String email, String password) async {
    final success = await authRepository.signup(email, password);
    if (success) {
      _isAuthenticated = true;
      // On assigne un rôle factice après un signup
      // Par exemple, on décide arbitrairement que les nouveaux inscrits sont des "aidants"
      _role = 'aidant';
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await authRepository.logout();
    _isAuthenticated = false;
    _role = null; // On réinitialise le rôle à null
    notifyListeners();
  }

  Future<bool> refresh() async {
    final refreshed = await authRepository.refreshToken();
    if (!refreshed) {
      // Si le refresh échoue, on déconnecte l’utilisateur et on perd son rôle
      await logout();
    }
    return refreshed;
  }
}