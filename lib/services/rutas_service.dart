import 'package:dashboardpro/core/env_config.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/model/rutas/rutas_response.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'package:dashboardpro/utils/secure_log.dart';

/// * Excepción personalizada para errores del servicio de rutas
class RutasException implements Exception {
  final String message;
  RutasException(this.message);

  @override
  String toString() => message;
}

/// * Servicio para consumir el endpoint de listado de rutas
/// Endpoint: GET /rutas/list
/// Requiere token de autenticación en el header
class RutasService {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  RutasService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': '*/*',
                },
              ),
            )..interceptors.add(SessionInterceptor());

  /// * Obtiene el listado de rutas
  /// Requiere token de autenticación en el header
  /// Endpoint: GET /rutas/list
  /// Headers: Authorization Bearer {token}, accept: */*
  Future<RutasResponse> obtenerRutas(String? token) async {
    try {
      final options = Options(
        headers: <String, dynamic>{
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      if (token != null && token.isNotEmpty) {
        SecureLog.dAuth('📤 Token', present: true);
      } else {
        SecureLog.d('⚠️ ADVERTENCIA: Token es null o vacío');
      }

      final response = await _dio.get(
        '/rutas/list',
        options: options,
      );


      if (response.statusCode == 200) {
        try {
          final rutasResponse = RutasResponse.fromJson(response.data);
          return rutasResponse;
        } catch (parseError, stackTrace) {
          throw RutasException(
              'Error al procesar la respuesta del servidor: ${parseError.toString()}');
        }
      } else {
        throw RutasException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw RutasException(
            'Tiempo de espera agotado. Verifica tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw RutasException(
            'Error de conexión. Verifica tu conexión a internet.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;


        String errorMessage = 'Error al obtener las rutas';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        // ! IMPORTANTE: Manejo de errores según especificación
        if (statusCode == 401 || statusCode == 403) {
          throw RutasException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 404) {
          throw RutasException('No se encontraron rutas.');
        } else if (statusCode == 500) {
          throw RutasException(
              'Error del servidor. Intenta más tarde.');
        } else {
          throw RutasException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener las rutas.');
        }
      } else {
        throw RutasException(
            'Error de conexión. Verifica tu conexión a internet.');
      }
    } on SocketException {
      throw RutasException(
          'Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      if (e is RutasException) {
        rethrow;
      }
      throw RutasException('Error inesperado: ${e.toString()}');
    }
  }
}
