import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;
  final FlutterSecureStorage secureStorage;

  AuthRepository({required this.authService, FlutterSecureStorage? storage})
      : secureStorage = storage ?? const FlutterSecureStorage();

  /// Tente de se connecter avec email et password.
  /// Renvoie true si succès, false sinon.
  Future<bool> login(String email, String password) async {
    try {
      final token = await authService.login(email, password);
      await secureStorage.write(key: 'auth_token', value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Tente de s’inscrire avec email et password.
  /// Renvoie true si succès, false sinon.
  Future<bool> signup(String email, String password) async {
    try {
      final token = await authService.signup(email, password);
      await secureStorage.write(key: 'auth_token', value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Déconnecte l’utilisateur en supprimant le token du stockage sécurisé.
  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
  }

  /// Récupère le token JWT s’il existe.
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  /// Tente de rafraîchir le token.
  /// Renvoie true si succès, false sinon.
  Future<bool> refreshToken() async {
    final oldToken = await getToken();
    if (oldToken == null) return false;

    try {
      final newToken = await authService.refreshToken(oldToken);
      await secureStorage.write(key: 'auth_token', value: newToken);
      return true;
    } catch (e) {
      return false;
    }
  }
}
