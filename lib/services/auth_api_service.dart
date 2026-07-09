import 'package:dashboardpro/core/env_config.dart';
import 'package:dashboardpro/services/auth_exception.dart';
import 'package:dashboardpro/model/auth/login_response.dart';
import 'package:dashboardpro/interceptors/rate_limit_interceptor.dart';
import 'package:dio/dio.dart';
import 'dart:io';

/// Cliente HTTP dedicado a la API de autenticación (apipay).
/// Sin interceptores para evitar ciclos en refresh de token.
class AuthApiService {
  AuthApiService._();

  static const Duration _timeout = Duration(seconds: 30);

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(RateLimitInterceptor());

  static String get _authBaseUrl => EnvConfig.authApiBaseUrl;

  /// POST /login
  static Future<LoginResponse> login({
    required String userName,
    required String password,
  }) async {
    final url = '$_authBaseUrl/login';
    try {
      final response = await _dio.post(
        url,
        data: {
          'userName': userName,
          'password': password,
        },
      );
      return _parseTokenPairResponse(response);
    } on DioException catch (e) {
      throw _mapLoginDioException(e);
    } on SocketException {
      throw AuthException('No hay conexión a internet. Revisa tu conexión.');
    }
  }

  /// POST /login/refresh — intercambia refresh token por nuevo par access + refresh.
  static Future<LoginResponse> refreshTokens({
    required String refreshToken,
  }) async {
    final url = '$_authBaseUrl/login/refresh';
    try {
      final response = await _dio.post(
        url,
        data: {
          'refreshToken': refreshToken,
        },
      );
      return _parseTokenPairResponse(response);
    } on DioException catch (e) {
      throw _mapRefreshDioException(e);
    } on SocketException {
      throw AuthException('No hay conexión a internet. Revisa tu conexión.');
    }
  }

  static LoginResponse _parseTokenPairResponse(Response<dynamic> response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException('Error en la respuesta del servidor de autenticación');
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw AuthException('Respuesta de autenticación inválida');
    }

    final loginResponse = LoginResponse.fromJson(data);
    if (loginResponse.token.isEmpty) {
      throw AuthException('No se recibió token de autenticación');
    }
    if (loginResponse.refreshToken.isEmpty) {
      throw AuthException('No se recibió refresh token');
    }

    return loginResponse;
  }

  static AuthException _mapLoginDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return AuthException(
        'Tiempo de espera agotado. Revisa tu conexión a internet.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      if (EnvConfig.usesWebDevProxy) {
        return AuthException(
          'Proxy de desarrollo no activo. Ejecuta en otra terminal: '
          'dart run tool/dev_api_proxy.dart',
        );
      }
      return AuthException('No hay conexión a internet. Revisa tu conexión.');
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    if (statusCode == 400 || statusCode == 401) {
      return AuthException('Usuario o contraseña incorrectos');
    }
    if (statusCode == 404) {
      var message = _extractErrorMessage(responseData);
      if (message.isEmpty) {
        message = e.response?.statusMessage ?? 'Not Found';
      }
      return AuthException(message);
    }
    if (statusCode == 500) {
      return AuthException('Error en el servidor. Intenta más tarde.');
    }
    if (e.response != null) {
      return AuthException(
        'Error al iniciar sesión: ${e.response!.statusMessage}',
      );
    }
    return AuthException('Error de conexión. Revisa tu conexión a internet.');
  }

  static AuthException _mapRefreshDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return AuthException(
        'Tiempo de espera agotado al renovar la sesión.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      if (EnvConfig.usesWebDevProxy) {
        return AuthException(
          'Proxy de desarrollo no activo. Ejecuta en otra terminal: '
          'dart run tool/dev_api_proxy.dart',
        );
      }
      return AuthException('No hay conexión a internet. Revisa tu conexión.');
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return AuthException('Sesión expirada. Inicia sesión nuevamente.');
    }

    var message = _extractErrorMessage(e.response?.data);
    if (message.isEmpty) {
      message = 'No se pudo renovar la sesión';
    }
    return AuthException(message);
  }

  static String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return '';
    if (responseData is String) return responseData.trim();
    if (responseData is Map<String, dynamic>) {
      return responseData['message']?.toString().trim() ??
          responseData['error']?.toString().trim() ??
          responseData['detail']?.toString().trim() ??
          responseData['msg']?.toString().trim() ??
          '';
    }
    if (responseData is Map) {
      final m = Map<String, dynamic>.from(responseData);
      return m['message']?.toString().trim() ??
          m['error']?.toString().trim() ??
          m['detail']?.toString().trim() ??
          m['msg']?.toString().trim() ??
          '';
    }
    return responseData.toString().trim();
  }
}
