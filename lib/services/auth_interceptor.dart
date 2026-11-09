import 'package:dio/dio.dart';
import 'package:segundoparcialflutter/services/token_service.dart';

class AuthInterceptor extends Interceptor {
  final Future<void> Function()? onUnauthorized;
  AuthInterceptor({this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenService.storage.read(key: TokenService.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: _messageFor(err),
    ));
  }

  String _messageFor(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Tiempo de espera agotado.';
      case DioExceptionType.badResponse:
        return switch (e.response?.statusCode) {
          400 => 'Petición incorrecta.',
          401 => 'No autorizado. Inicia sesión nuevamente.',
          404 => 'Recurso no encontrado.',
          500 => 'Error del servidor. Intenta más tarde.',
          final c => 'Error del servidor ($c).',
        };
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return 'No hay conexión a internet o el servidor no responde.';
      case DioExceptionType.cancel:
        return 'Petición cancelada.';
      case DioExceptionType.badCertificate:
        return 'Certificado no válido.';
    }
  }
}
