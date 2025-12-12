import 'package:dio/dio.dart';
import 'package:dashboardpro/model/auth/login_response.dart';
import 'package:dashboardpro/model/auth/registro_request.dart';
import 'package:dashboardpro/model/auth/registro_response.dart';
import 'package:dashboardpro/model/auth/verify_request.dart';
import 'package:dashboardpro/model/auth/verify_response.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

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

  /// Registra un nuevo pasajero
  Future<RegistroResponse> registerPasajero(RegistroRequest request) async {
    try {
      final response = await _dio.post(
        '/login/pasajero/registro',
        data: request.toJson(),
      );

      // Aceptar tanto 200 (OK) como 201 (Created) como respuestas exitosas
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Agregar logging para debug
        debugPrint(
            '📦 Respuesta del servidor (${response.statusCode}): ${response.data}');
        debugPrint('📦 Tipo de respuesta: ${response.data.runtimeType}');

        try {
          // Manejar diferentes formatos de respuesta
          if (response.data is Map<String, dynamic>) {
            try {
              return RegistroResponse.fromJson(
                  response.data as Map<String, dynamic>);
            } catch (parseError) {
              debugPrint('⚠️ Error al parsear RegistroResponse: $parseError');
              // Si el parseo falla pero el código es exitoso, crear respuesta básica
              return RegistroResponse(
                status: 'success',
                message: 'Usuario registrado exitosamente',
                data: RegistroData(id: 0, nombre: ''),
              );
            }
          } else if (response.data == null ||
              response.data.toString().isEmpty) {
            // Si la respuesta está vacía pero el código es exitoso
            debugPrint(
                '⚠️ Respuesta vacía pero código exitoso, creando respuesta básica');
            return RegistroResponse(
              status: 'success',
              message: 'Usuario registrado exitosamente',
              data: RegistroData(id: 0, nombre: ''),
            );
          } else {
            // Si la respuesta no es un Map, intentar crear una respuesta básica
            debugPrint(
                '⚠️ La respuesta no es un Map, creando respuesta básica');
            debugPrint(
                '⚠️ Tipo de dato recibido: ${response.data.runtimeType}');
            return RegistroResponse(
              status: 'success',
              message: 'Usuario registrado exitosamente',
              data: RegistroData(id: 0, nombre: ''),
            );
          }
        } catch (e) {
          debugPrint('❌ Error inesperado al procesar respuesta exitosa: $e');
          // Si hay un error pero el código es 201, asumir que el registro fue exitoso
          return RegistroResponse(
            status: 'success',
            message: 'Usuario registrado exitosamente',
            data: RegistroData(id: 0, nombre: ''),
          );
        }
      } else {
        debugPrint('❌ Código de estado inesperado: ${response.statusCode}');
        throw AuthException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
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
        final responseData = e.response!.data;

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al registrar usuario';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        }

        if (statusCode == 400) {
          throw AuthException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Datos inválidos. Verifica la información ingresada.');
        } else if (statusCode == 409) {
          throw AuthException(
              'El correo electrónico o número de monedero ya está registrado.');
        } else if (statusCode == 500) {
          throw AuthException('Error en el servidor. Intenta más tarde.');
        } else {
          throw AuthException(
              'Error al registrar: ${errorMessage.isNotEmpty ? errorMessage : e.response!.statusMessage}');
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
      debugPrint('❌ Error inesperado en registerPasajero: $e');
      debugPrint('❌ Tipo de error: ${e.runtimeType}');
      throw AuthException('Error inesperado: ${e.toString()}');
    }
  }

  /// Verifica el código de verificación de email
  /// El endpoint espera: PATCH /login/verify con body { "codigo": "1234" }
  Future<VerifyResponse> verifyEmail(VerifyRequest request) async {
    try {
      final requestData = request.toJson();
      debugPrint('📤 Request body para verificación: $requestData');
      debugPrint('📤 Código a enviar: ${request.codigo}');
      debugPrint('📤 Método HTTP: PATCH');
      debugPrint('📤 URL completa: $baseUrl/login/verify');

      final response = await _dio.patch(
        '/login/verify',
        data: requestData,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Headers de respuesta: ${response.headers}');

      // Aceptar 200 (OK), 201 (Created) y 204 (No Content) como respuestas exitosas
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        debugPrint(
            '📦 Respuesta de verificación (${response.statusCode}): ${response.data}');
        debugPrint('📦 Tipo de respuesta: ${response.data.runtimeType}');

        try {
          // Si la respuesta es un String, tratarlo como mensaje de éxito
          if (response.data is String) {
            return VerifyResponse(
              success: true,
              message: response.data as String,
              isExpired: false,
            );
          }
          // Si es un Map, parsearlo normalmente
          // Si es null (204 No Content), crear respuesta de éxito
          if (response.data == null) {
            return VerifyResponse(
              success: true,
              message: 'Código verificado exitosamente',
              isExpired: false,
            );
          }
          return VerifyResponse.fromJson(response.data);
        } catch (parseError) {
          debugPrint('⚠️ Error al parsear VerifyResponse: $parseError');
          // Si el parseo falla pero el código es exitoso, crear respuesta básica
          return VerifyResponse(
            success: true,
            message: 'Código verificado exitosamente',
            isExpired: false,
          );
        }
      } else {
        debugPrint('❌ Código de estado inesperado: ${response.statusCode}');
        throw AuthException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
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
        final responseData = e.response!.data;
        final responseHeaders = e.response!.headers;

        debugPrint('❌ ========== ERROR EN VERIFICACIÓN ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ Headers de respuesta: $responseHeaders');
        debugPrint('❌ Request enviado: ${request.toJson()}');
        debugPrint('❌ Código: ${request.codigo}');
        debugPrint('❌ URL: $baseUrl/login/verify');
        debugPrint('❌ Método: PATCH');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al verificar el código';
        bool isExpired = false;

        // Si la respuesta es un String
        if (responseData is String) {
          errorMessage = responseData;
          isExpired = responseData.contains('expirado') ||
              responseData.toLowerCase().contains('expired') ||
              responseData == 'El código ha expirado';
        } else if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
          isExpired = errorMessage.contains('expirado') ||
              errorMessage.toLowerCase().contains('expired') ||
              errorMessage == 'El código ha expirado';
        }

        if (statusCode == 400) {
          throw AuthException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Código inválido. Verifica el código ingresado.');
        } else if (statusCode == 401) {
          throw AuthException('Código de verificación incorrecto o expirado.');
        } else if (statusCode == 404) {
          throw AuthException('Usuario no encontrado.');
        } else if (statusCode == 500) {
          throw AuthException('Error en el servidor. Intenta más tarde.');
        } else {
          // Si el mensaje indica expiración, lanzar excepción especial
          if (isExpired) {
            throw AuthException(errorMessage);
          }
          throw AuthException(
              'Error al verificar: ${errorMessage.isNotEmpty ? errorMessage : e.response!.statusMessage}');
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
      debugPrint('❌ Error inesperado en verifyEmail: $e');
      debugPrint('❌ Tipo de error: ${e.runtimeType}');
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
