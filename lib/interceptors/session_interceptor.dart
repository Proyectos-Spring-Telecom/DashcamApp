import 'package:dio/dio.dart';
import 'package:dashboardpro/services/session_manager.dart';
import 'package:flutter/foundation.dart';

/// * Interceptor de Dio para manejar expiración de sesión
/// Detecta automáticamente cuando el token expira y cierra sesión
class SessionInterceptor extends Interceptor {
  // * Endpoints públicos que no requieren autenticación
  static const List<String> _publicEndpoints = [
    '/login',
    '/register',
    '/forgot-password',
    '/resend-code',
    '/verify-code',
    '/clientes/public', // * Endpoint público de clientes
  ];

  /// * Verifica si un endpoint es público (no requiere autenticación)
  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    final requestPath = err.requestOptions.path;

    // * Ignorar endpoints públicos (login, registro, etc.)
    if (_isPublicEndpoint(requestPath)) {
      super.onError(err, handler);
      return;
    }

    // * Verificar si la respuesta indica sesión inválida
    if (SessionManager.isSessionInvalid(responseData, statusCode)) {
      debugPrint('🔐 Interceptor detectó sesión inválida');
      debugPrint('📋 Status Code: $statusCode');
      debugPrint('📋 Request Path: $requestPath');
      debugPrint('📋 Response Data: $responseData');

      // * Rechazar la petición inmediatamente para resolver el handler
      // * Esto asegura que el handler siempre se resuelva, evitando estados indefinidos
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: 'Sesión expirada',
        ),
      );

      // * Manejar expiración de sesión en segundo plano (sin bloquear el handler)
      // * Esto se hace después de resolver el handler para no dejar el request en estado indefinido
      SessionManager.handleSessionExpired(null).catchError((error) {
        debugPrint('❌ Error al manejar sesión expirada: $error');
      });

      return;
    }

    // * Si no es un error de sesión, continuar con el manejo normal
    super.onError(err, handler);
  }
}
