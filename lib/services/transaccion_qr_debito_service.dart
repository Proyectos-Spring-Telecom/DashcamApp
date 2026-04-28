import 'package:dashboardpro/core/env_config.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/model/transaccion/transacciones_response.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// ! SERVICIO: Transacciones Débito QR
// ? INFO: Obtiene transacciones débito QR (esQR = true) con paginación.
// ⚠️ WARNING: No modificar lógica de filtrado por rol (backend).

/// * Excepción personalizada para errores del servicio de transacciones débito QR.
class TransaccionQrDebitoException implements Exception {
  final String message;
  TransaccionQrDebitoException(this.message);

  @override
  String toString() => message;
}

/// * Servicio para consumir el endpoint de listado paginado de transacciones débito QR.
/// Endpoint: POST /transacciones/paginado/debito-qr
/// Requiere token de autenticación en el header.
/// Body: page, limit, fechaInicio (YYYY-MM-DD), fechaFin (YYYY-MM-DD).
class TransaccionQrDebitoService {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  TransaccionQrDebitoService({Dio? dio})
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

  /// * Obtiene el listado paginado de transacciones débito QR.
  /// [token] Token de autenticación.
  /// [page] Número de página (>= 1).
  /// [limit] Cantidad por página (ej. 20).
  /// [fechaInicio] Fecha inicio en formato YYYY-MM-DD.
  /// [fechaFin] Fecha fin en formato YYYY-MM-DD.
  /// Respuesta: data (listado), paginated (paginación).
  Future<TransaccionesResponse> obtenerTransaccionesDebitoQr(
    String? token, {
    required int page,
    required int limit,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    try {
      if (page < 1) {
        throw TransaccionQrDebitoException('El número de página debe ser mayor a 0.');
      }
      if (limit < 1) {
        throw TransaccionQrDebitoException('El límite debe ser mayor a 0.');
      }

      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'accept': '*/*',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final requestBody = {
        'page': page,
        'limit': limit,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
      };

      debugPrint('📤 Obteniendo transacciones débito QR (paginado)');
      debugPrint('📤 URL: $baseUrl/transacciones/paginado/debito-qr');
      debugPrint('📤 Método: POST');
      debugPrint('📤 Body: $requestBody');

      final response = await _dio.post(
        '/transacciones/paginado/debito-qr',
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint('📥 Status Code: ${response.statusCode}');

      // ? INFO: El servicio devuelve 201 (Created) en respuesta exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.data is Map<String, dynamic>) {
            final transaccionesResponse =
                TransaccionesResponse.fromJson(response.data as Map<String, dynamic>);
            debugPrint('✅ Transacciones débito QR: ${transaccionesResponse.data.length}');
            return transaccionesResponse;
          }
          throw TransaccionQrDebitoException(
              'Error al procesar la respuesta del servidor: formato inválido.');
        } catch (e) {
          if (e is TransaccionQrDebitoException) rethrow;
          debugPrint('❌ Error al parsear respuesta: $e');
          throw TransaccionQrDebitoException(
              'Error al procesar la respuesta del servidor.');
        }
      }

      if (response.statusCode == 400) {
        String msg = 'Datos inválidos.';
        if (response.data is Map<String, dynamic>) {
          final m = response.data as Map<String, dynamic>;
          msg = m['message']?.toString() ?? m['error']?.toString() ?? msg;
        }
        throw TransaccionQrDebitoException(msg);
      }

      throw TransaccionQrDebitoException(
          'Error en la respuesta del servidor (código: ${response.statusCode})');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw TransaccionQrDebitoException(
            'Tiempo de espera agotado. Verifica tu conexión.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw TransaccionQrDebitoException(
            'Error de conexión. Verifica tu conexión a internet.');
      }
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;
        String errorMessage = 'Error al obtener transacciones QR';
        if (data is Map<String, dynamic>) {
          errorMessage = data['message']?.toString() ??
              data['error']?.toString() ??
              errorMessage;
        } else if (data is String) {
          errorMessage = data;
        }
        if (statusCode == 400) {
          throw TransaccionQrDebitoException(errorMessage);
        }
        if (statusCode == 401 || statusCode == 403) {
          throw TransaccionQrDebitoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        }
        throw TransaccionQrDebitoException(errorMessage);
      }
      throw TransaccionQrDebitoException(
          'Error de conexión. Verifica tu conexión a internet.');
    } on SocketException {
      throw TransaccionQrDebitoException(
          'Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      if (e is TransaccionQrDebitoException) rethrow;
      debugPrint('❌ Error inesperado en obtenerTransaccionesDebitoQr: $e');
      throw TransaccionQrDebitoException(
          'No fue posible cargar la información. Intenta más tarde.');
    }
  }
}
