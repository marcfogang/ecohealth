
import 'package:dio/dio.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/interceptors.dart'; // l’intercepteur qu’on vient de créer

class ApiClient {
  final Dio dio;

  ApiClient._internal(this.dio);

  // Singleton, pour avoir une seule instance d'ApiClient
  static ApiClient? _instance;
  static ApiClient getInstance(AuthRepository authRepository) {
    if (_instance == null) {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://example.com/api', // URL de base du backend
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      // Ajout de l’intercepteur
      dio.interceptors.add(JwtInterceptor(authRepository));

      _instance = ApiClient._internal(dio);
    }
    return _instance!;
  }

  // Exemple d’une méthode GET
  Future<Response> getData(String endpoint) async {
    return await dio.get(endpoint);
  }

  // Exemple d’une méthode POST
  Future<Response> postData(String endpoint, Map<String, dynamic> data) async {
    return await dio.post(endpoint, data: data);
  }
}
