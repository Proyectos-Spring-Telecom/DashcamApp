import 'package:dashboardpro/core/env_config.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/model/zonas/zonas_response.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'package:dashboardpro/utils/secure_log.dart';

/// * Excepción personalizada para errores del servicio de zonas
class ZonasException implements Exception {
  final String message;
  ZonasException(this.message);

  @override
  String toString() => message;
}

/// * Servicio para consumir el endpoint de listado de zonas
/// Endpoint: GET /zonas/list
/// Requiere token de autenticación en el header
class ZonasService {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  ZonasService({Dio? dio})
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

  /// * Obtiene el listado de zonas
  /// Requiere token de autenticación en el header
  /// Endpoint: GET /zonas/list
  /// Headers: Authorization Bearer {token}, accept: */*
  Future<ZonasResponse> obtenerZonas(String? token) async {
    try {
      final options = Options(
        headers: <String, dynamic>{
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      if (token != null && token.isNotEmpty) {
        SecureLog.dAuth('📤 Token', present: token != null && token.isNotEmpty);
      } else {
        SecureLog.d('⚠️ ADVERTENCIA: Token es null o vacío');
      }

      final response = await _dio.get(
        '/zonas/list',
        options: options,
      );


      if (response.statusCode == 200) {
        try {
          // ? INFO: API puede devolver { "data": [...] } o el array directo
          final zonasResponse = ZonasResponse.fromJson(response.data);
          return zonasResponse;
        } catch (parseError, stackTrace) {
          throw ZonasException(
              'Error al procesar la respuesta del servidor: ${parseError.toString()}');
        }
      } else {
        throw ZonasException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ZonasException(
            'Tiempo de espera agotado. Verifica tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw ZonasException(
            'Error de conexión. Verifica tu conexión a internet.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;


        String errorMessage = 'Error al obtener las zonas';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        // ! IMPORTANTE: Manejo de errores según especificación
        if (statusCode == 401 || statusCode == 403) {
          throw ZonasException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 404) {
          throw ZonasException('No se encontraron zonas.');
        } else if (statusCode == 500) {
          throw ZonasException(
              'Error del servidor. Intenta más tarde.');
        } else {
          throw ZonasException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener las zonas.');
        }
      } else {
        throw ZonasException(
            'Error de conexión. Verifica tu conexión a internet.');
      }
    } on SocketException {
      throw ZonasException(
          'Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      if (e is ZonasException) {
        rethrow;
      }
      throw ZonasException('Error inesperado: ${e.toString()}');
    }
  }
}
