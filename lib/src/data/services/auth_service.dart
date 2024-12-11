
import 'dart:async';

class AuthService {
  /// Simule un appel de connexion.
  /// En pratique, vous utiliserez un client HTTP (Dio, http)
  /// et ferez une requête POST vers /auth/login avec {email, password}.
  Future<String> login(String email, String password) async {
    // Simule un temps de réponse réseau
    await Future.delayed(const Duration(seconds: 1));

    // Simulation simple : si email et password sont non vides, on retourne un token factice
    if (email.isNotEmpty && password.isNotEmpty) {
      return "fake_jwt_token_123";
    } else {
      throw Exception("Invalid credentials");
    }
  }

  /// Simule l'inscription d'un nouvel utilisateur.
  /// En pratique, requête POST /auth/signup avec {email, password, ...}
  Future<String> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation simple : si les champs sont remplis, on retourne un autre token factice
    if (email.isNotEmpty && password.isNotEmpty) {
      return "fake_jwt_token_new_user_456";
    } else {
      throw Exception("Invalid signup data");
    }
  }

  /// Simule le rafraîchissement du token.
  /// En pratique, requête POST /auth/refresh avec l'ancien token.
  Future<String> refreshToken(String oldToken) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation : si l'ancien token est "fake_jwt_token_123", on en donne un nouveau
    if (oldToken == "fake_jwt_token_123" || oldToken == "fake_jwt_token_new_user_456") {
      return "fake_jwt_token_refreshed_789";
    } else {
      throw Exception("Cannot refresh token");
    }
  }
}
