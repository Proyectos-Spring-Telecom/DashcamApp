import 'package:dio/dio.dart';
import 'package:dashboardpro/model/rutas/rutas_response.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

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
  static const String baseUrl = 'https://dashcampay.com/apidev';

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

      debugPrint('📤 Obteniendo rutas');
      debugPrint('📤 URL: $baseUrl/rutas/list');
      debugPrint('📤 Método: GET');
      if (token != null && token.isNotEmpty) {
        debugPrint(
            '📤 Token (primeros 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
      } else {
        debugPrint('⚠️ ADVERTENCIA: Token es null o vacío');
      }

      final response = await _dio.get(
        '/rutas/list',
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final rutasResponse = RutasResponse.fromJson(response.data);
          debugPrint('✅ Rutas obtenidas exitosamente');
          debugPrint('✅ Total de rutas: ${rutasResponse.data.length}');
          debugPrint('✅ Rutas activas (dropdown): ${rutasResponse.rutasActivas.length}');
          debugPrint('✅ Rutas para mapa: ${rutasResponse.rutasParaMapa.length}');
          return rutasResponse;
        } catch (parseError, stackTrace) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          debugPrint('❌ Stack trace: $stackTrace');
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

        debugPrint('❌ ========== ERROR EN OBTENER RUTAS ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ =============================================');

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
      debugPrint('❌ Error inesperado en obtenerRutas: $e');
      throw RutasException('Error inesperado: ${e.toString()}');
    }
  }
}
