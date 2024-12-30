// lib/src/data/services/auth_service.dart

import 'package:hive/hive.dart';

class AuthService {
  final Box userBox;

  AuthService({required this.userBox});

  Future<String> login(String email, String password, String role) async {
    final userEntry = userBox.values.firstWhere(
      (u) => u is Map && u['email'] == email && u['password'] == password && u['role'] == role,
      orElse: () => null,
    );

    if (userEntry == null) {
      throw Exception("Invalid credentials or role");
    }

    final Map userData = userEntry as Map;
    return userData['token'];
  }

  Future<String> signup(String email, String password, String role) async {
    // Token factice
    final token = "fake_jwt_token_${DateTime.now().millisecondsSinceEpoch}";
    final userData = {
      'email': email,
      'password': password,
      'token': token,
      'role': role,
    };

    await userBox.put(email, userData);
    return token;
  }

  Future<String> refreshToken(String oldToken) async {
    final newToken = "fake_jwt_token_refreshed_${DateTime.now().millisecondsSinceEpoch}";
    String? userKey;
    for (var key in userBox.keys) {
      final user = userBox.get(key);
      if (user['token'] == oldToken) {
        userKey = key;
        break;
      }
    }

    if (userKey != null) {
      final user = userBox.get(userKey);
      user['token'] = newToken;
      await userBox.put(userKey, user);
    }
    return newToken;
  }
}
