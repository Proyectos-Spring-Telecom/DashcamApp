import 'package:dio/dio.dart';
import 'package:dashboardpro/model/auth/login_response.dart';
import 'dart:io';

class AuthService {
  final Dio _dio;
  static const String baseUrl = 'https://dashcampay.com/api';

  AuthService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Realiza el login del usuario
  Future<LoginResponse> login(String userName, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'userName': userName,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw AuthException('Error en la respuesta del servidor');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw AuthException(
            'Tiempo de espera agotado. Revisa tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw AuthException('No hay conexión a internet. Revisa tu conexión.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 400 || statusCode == 401) {
          throw AuthException('Usuario o contraseña incorrectos');
        } else if (statusCode == 500) {
          throw AuthException('Error en el servidor. Intenta más tarde.');
        } else {
          throw AuthException(
              'Error al iniciar sesión: ${e.response!.statusMessage}');
        }
      } else {
        throw AuthException(
            'Error de conexión. Revisa tu conexión a internet.');
      }
    } on SocketException {
      throw AuthException('No hay conexión a internet. Revisa tu conexión.');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Error inesperado: ${e.toString()}');
    }
  }
}

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
