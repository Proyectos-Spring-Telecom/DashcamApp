import 'package:dio/dio.dart';
import 'package:dashboardpro/model/direccion/codigo_postal_model.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DireccionService {
  final Dio _dio;
  static const String baseUrl = 'https://dashcampay.com/apidev';

  DireccionService({Dio? dio})
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
            )..interceptors.add(SessionInterceptor());

  /// Consulta la información de dirección por código postal
  /// Endpoint: GET /direcciones/CP/{cp}
  /// Requiere token de autenticación en el header
  Future<CodigoPostalResponse> consultarPorCodigoPostal(String cp, String? token) async {
    try {
      // Validar código postal
      if (cp.isEmpty) {
        throw DireccionException('El código postal no puede estar vacío.');
      }

      if (cp.length != 5) {
        throw DireccionException('El código postal debe tener 5 dígitos.');
      }

      // Validar que solo contenga dígitos
      if (!RegExp(r'^\d+$').hasMatch(cp)) {
        throw DireccionException('El código postal solo puede contener dígitos.');
      }

      // Configurar headers con token de autenticación
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      debugPrint('📤 Consultando dirección por código postal: $cp');
      debugPrint('📤 URL: $baseUrl/direcciones/CP/$cp');
      debugPrint('📤 Método: GET');
      debugPrint('📤 Token: ${token != null ? 'Presente' : 'No presente'}');

      final response = await _dio.get(
        '/direcciones/CP/$cp',
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final responseData = Map<String, dynamic>.from(response.data as Map);
          final codigoPostalResponse =
              CodigoPostalResponse.fromJson(responseData);

          // Verificar si hay error en la respuesta
          if (codigoPostalResponse.error) {
            debugPrint('⚠️ La respuesta indica un error: ${codigoPostalResponse.message}');
            throw DireccionException(codigoPostalResponse.message.isNotEmpty
                ? codigoPostalResponse.message
                : 'Error al consultar el código postal.');
          }

          // Verificar que se recibió información del código postal
          if (codigoPostalResponse.codigoPostal == null) {
            debugPrint('⚠️ La respuesta no contiene información del código postal');
            throw DireccionException('No se encontró información para el código postal proporcionado.');
          }

          debugPrint('✅ Código postal consultado exitosamente');
          debugPrint('✅ Estado: ${codigoPostalResponse.codigoPostal!.estado}');
          debugPrint('✅ Municipio: ${codigoPostalResponse.codigoPostal!.municipio}');
          debugPrint('✅ Colonias: ${codigoPostalResponse.codigoPostal!.colonias.length}');

          return codigoPostalResponse;
        } catch (parseError) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          throw DireccionException(
              'Error al procesar la respuesta del servidor.');
        }
      } else {
        throw DireccionException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw DireccionException(
            'Tiempo de espera agotado. Intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw DireccionException(
            'No se pudo conectar con el servidor. Verifica tu conexión a internet.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN CONSULTA DE CÓDIGO POSTAL ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ======================================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al consultar el código postal';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 400) {
          throw DireccionException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Código postal inválido.');
        } else if (statusCode == 401 || statusCode == 403) {
          throw DireccionException(
              'No autorizado. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 404) {
          throw DireccionException(
              'No se encontró información para el código postal proporcionado.');
        } else if (statusCode == 500) {
          throw DireccionException(
              'Error en el servidor. Intenta más tarde.');
        } else {
          throw DireccionException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al consultar el código postal.');
        }
      } else {
        throw DireccionException(
            'No se pudo obtener la información. Intenta más tarde.');
      }
    } on SocketException {
      throw DireccionException(
          'No se pudo conectar con el servidor. Verifica tu conexión a internet.');
    } catch (e) {
      if (e is DireccionException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en consultarPorCodigoPostal: $e');
      throw DireccionException('Error inesperado: ${e.toString()}');
    }
  }
}

/// Excepción personalizada para errores relacionados con direcciones
class DireccionException implements Exception {
  final String message;

  DireccionException(this.message);

  @override
  String toString() => message;
}

