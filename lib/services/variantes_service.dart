import 'package:dashboardpro/core/env_config.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/model/variantes/variantes_response.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// * Excepción personalizada para errores del servicio de variantes
class VariantesException implements Exception {
  final String message;
  VariantesException(this.message);

  @override
  String toString() => message;
}

/// * Servicio para consumir el endpoint de listado de variantes
/// Endpoint: GET /variantes/list
/// Requiere token de autenticación en el header
class VariantesService {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  VariantesService({Dio? dio})
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

  /// * Obtiene el listado de variantes
  /// Requiere token de autenticación en el header
  /// Endpoint: GET /variantes/list
  Future<VariantesResponse> obtenerVariantes(String? token) async {
    try {
      final options = Options(
        headers: <String, dynamic>{
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      debugPrint('📤 Obteniendo variantes');
      debugPrint('📤 URL: $baseUrl/variantes/list');
      if (token != null && token.isNotEmpty) {
        debugPrint(
            '📤 Token (primeros 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
      } else {
        debugPrint('⚠️ ADVERTENCIA: Token es null o vacío');
      }

      final response = await _dio.get(
        '/variantes/list',
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final variantesResponse = VariantesResponse.fromJson(response.data);
          debugPrint('✅ Variantes obtenidas exitosamente');
          debugPrint('✅ Total de variantes: ${variantesResponse.data.length}');
          return variantesResponse;
        } catch (parseError, stackTrace) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          debugPrint('❌ Stack trace: $stackTrace');
          throw VariantesException(
              'Error al procesar la respuesta del servidor. Intenta más tarde.');
        }
      } else {
        throw VariantesException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw VariantesException(
            'Tiempo de espera agotado. Verifica tu conexión a internet.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw VariantesException(
            'Error de conexión. Verifica tu conexión a internet.');
      }
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'No fue posible cargar las variantes';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        if (statusCode == 401 || statusCode == 403) {
          throw VariantesException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        }
        if (statusCode == 404) {
          throw VariantesException('No se encontraron variantes.');
        }
        if (statusCode == 500) {
          throw VariantesException('Error del servidor. Intenta más tarde.');
        }
        throw VariantesException(errorMessage);
      }
      throw VariantesException(
          'Error de conexión. Verifica tu conexión a internet.');
    } on SocketException {
      throw VariantesException(
          'Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      if (e is VariantesException) rethrow;
      debugPrint('❌ Error inesperado en obtenerVariantes: $e');
      throw VariantesException('No fue posible cargar las variantes.');
    }
  }
}
