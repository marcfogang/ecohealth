// lib/src/presentation/state/auth_provider.dart

import 'package:flutter/foundation.dart';
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
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser != null && currentUser['token'] != null) {
      _isAuthenticated = true;
      _role = currentUser['role'];
    } else {
      _isAuthenticated = false;
      _role = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, String role) async {
    final success = await authRepository.login(email, password, role);
    if (success) {
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        _isAuthenticated = true;
        _role = currentUser['role'];
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> signup(String email, String password, String role) async {
    final success = await authRepository.signup(email, password, role);
    if (success) {
      // Pas de redirection ici, on ne met pas currentUser, on reste déco
      // L'utilisateur doit se connecter manuellement
      // On ne change pas isAuthenticated, reste false
      // On ne définit pas de role
      // Juste return success
    }
    return success;
  }

  Future<void> logout() async {
    await authRepository.logout();
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }

  Future<bool> refresh() async {
    final refreshed = await authRepository.refreshToken();
    if (!refreshed) {
      await logout();
    } else {
      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        _role = currentUser['role'];
        _isAuthenticated = true;
        notifyListeners();
      }
    }
    return refreshed;
  }
}
