import 'package:dio/dio.dart';
import '../data/repositories/auth_repository.dart';

class JwtInterceptor extends Interceptor {
  final AuthRepository authRepository;

  JwtInterceptor(this.authRepository);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Récupérer le token depuis le AuthRepository
    final token = await authRepository.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Si on reçoit un 401, tente de rafraîchir le token
    if (err.response?.statusCode == 401) {
      final refreshed = await authRepository.refreshToken();
      if (refreshed) {
        // Si le rafraîchissement est un succès, on retente la requête
        final newToken = await authRepository.getToken();
        if (newToken != null && newToken.isNotEmpty) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          // Créer une nouvelle instance de Dio pour retenter la requête
          final newDio = Dio();
          // (Vous pouvez réutiliser la même instance mais attention aux boucles infinies)
          final response = await newDio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } else {
        // Si on n'a pas pu rafraîchir le token, on peut déconnecter l'utilisateur
        await authRepository.logout();
        // Vous pouvez éventuellement naviguer vers l'écran de login ici, mais c'est
        // généralement géré au niveau de l'UI en écoutant l'état du AuthProvider.
      }
    }

    return handler.next(err);
  }
}