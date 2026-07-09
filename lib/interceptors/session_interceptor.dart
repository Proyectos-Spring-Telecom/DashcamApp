import 'package:dio/dio.dart';
import 'package:dashboardpro/services/session_manager.dart';
import 'package:dashboardpro/services/token_refresh_service.dart';
import 'package:dashboardpro/interceptors/rate_limit_interceptor.dart';
import 'package:flutter/foundation.dart';

/// Interceptor de Dio: renueva token en 401 y cierra sesión si falla.
class SessionInterceptor extends Interceptor {
  static const List<String> _publicEndpoints = [
    '/login',
    '/login/refresh',
    '/register',
    '/forgot-password',
    '/resend-code',
    '/verify-code',
    '/clientes/public',
  ];

  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) return false;

    final path = err.requestOptions.path;
    if (_isPublicEndpoint(path)) return false;

    final alreadyRetried =
        err.requestOptions.extra[TokenRefreshService.retriedExtraKey] == true;
    return !alreadyRetried;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (RateLimitInterceptor.tryHandle(err, handler)) return;

    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    final requestPath = err.requestOptions.path;

    if (_shouldAttemptRefresh(err)) {

      final refreshed = await TokenRefreshService.refreshSession();
      if (refreshed != null && refreshed.token.isNotEmpty) {
        try {
          final requestOptions = err.requestOptions;
          final headers = Map<String, dynamic>.from(requestOptions.headers);
          headers['Authorization'] = 'Bearer ${refreshed.token}';

          final extra = Map<String, dynamic>.from(requestOptions.extra);
          extra[TokenRefreshService.retriedExtraKey] = true;

          final retryOptions = requestOptions.copyWith(
            headers: headers,
            extra: extra,
          );

          final response = await Dio().fetch(retryOptions);
          handler.resolve(response);
          return;
        } catch (retryError) {
        }
      }
    }

    if (_isPublicEndpoint(requestPath)) {
      handler.next(err);
      return;
    }

    if (SessionManager.isSessionInvalid(responseData, statusCode)) {
      if (kDebugMode) {
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: 'Sesión expirada',
        ),
      );

      SessionManager.handleSessionExpired(null).catchError((error) {
      });
      return;
    }

    handler.next(err);
  }
}
