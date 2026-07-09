import 'package:dashboardpro/core/env_config.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/model/monitoreo/monitoreo_response.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'package:dashboardpro/utils/secure_log.dart';

/// * Excepción personalizada para errores del servicio de monitoreo
class MonitoreoException implements Exception {
  final String message;
  MonitoreoException(this.message);

  @override
  String toString() => message;
}

/// * Servicio para consumir el endpoint de monitoreo de unidades
/// Endpoint: GET /monitoreo
/// Requiere token de autenticación en el header
class MonitoreoService {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  MonitoreoService({Dio? dio})
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

  /// * Obtiene el listado de unidades (vehículos) filtradas por cliente
  /// Requiere token de autenticación en el header
  /// Endpoint: GET /monitoreo
  /// El filtrado por cliente y clientes hijos se hace automáticamente en el backend
  Future<MonitoreoResponse> obtenerUnidades(String? token) async {
    try {
      // * Configurar headers con token de autenticación
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (token != null && token.isNotEmpty) {
        SecureLog.dAuth('📤 Token', present: true);
      } else {
        SecureLog.d('⚠️ ADVERTENCIA: Token es null o vacío');
      }

      final response = await _dio.get(
        '/monitoreo',
        options: options,
      );


      // * Aceptar 200 (OK) como respuesta exitosa
      if (response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final monitoreoResponse = MonitoreoResponse.fromJson(responseData);
            return monitoreoResponse;
          } else {
            throw MonitoreoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
          throw MonitoreoException(
              'Error al procesar la respuesta del servidor: ${parseError.toString()}');
        }
      } else {
        throw MonitoreoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonitoreoException(
            'Tiempo de espera agotado. Verifica tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonitoreoException(
            'Error de conexión. Verifica tu conexión a internet.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;


        // * Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener las unidades';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        // * ERROR HANDLING: Manejo específico de códigos de estado
        if (statusCode == 401 || statusCode == 403) {
          throw MonitoreoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 404) {
          throw MonitoreoException('No se encontraron unidades.');
        } else if (statusCode == 500) {
          throw MonitoreoException(
              'Error del servidor. Intenta más tarde.');
        } else {
          throw MonitoreoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener las unidades.');
        }
      } else {
        throw MonitoreoException(
            'Error de conexión. Verifica tu conexión a internet.');
      }
    } on SocketException {
      throw MonitoreoException(
          'Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      if (e is MonitoreoException) {
        rethrow;
      }
      throw MonitoreoException('Error inesperado: ${e.toString()}');
    }
  }
}
