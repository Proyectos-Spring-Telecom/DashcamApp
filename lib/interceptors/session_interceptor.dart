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

      // * Manejar expiración de sesión (sin contexto, se usará el navigator key)
      SessionManager.handleSessionExpired(null).then((_) {
        // * Rechazar la petición con un error específico
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: 'Sesión expirada',
          ),
        );
      });

      return;
    }

    // * Si no es un error de sesión, continuar con el manejo normal
    super.onError(err, handler);
  }
}
