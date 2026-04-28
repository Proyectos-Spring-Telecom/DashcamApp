import 'package:dashboardpro/core/env_config.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/data/models/extravio_report_response_model.dart';
import 'package:dashboardpro/domain/entities/extravio_report_request.dart';

class ExtravioRemoteDataSource {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  ExtravioRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  Future<ExtravioReportResponseModel> reportarExtravio({
    required ExtravioReportRequest request,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null && token.isNotEmpty
            ? {'Authorization': 'Bearer $token'}
            : {},
      );

      final response = await _dio.post(
        '/monederos/reporte/extravio',
        data: request.toJson(),
        options: options,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return ExtravioReportResponseModel.fromJson(data);
        }
        return ExtravioReportResponseModel(
          message: 'Reporte enviado correctamente.',
          status: 'success',
        );
      }

      throw ExtravioException(
        message:
            'Error en la respuesta del servidor (código: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final message = _extractMessage(data) ??
          (statusCode == 400
              ? 'Datos inválidos. Verifica el número de serie.'
              : statusCode == 404
                  ? 'Recurso no encontrado. Intenta más tarde.'
                  : 'No se pudo procesar la solicitud. Intenta más tarde.');

      throw ExtravioException(message: message, statusCode: statusCode);
    } catch (e) {
      if (e is ExtravioException) {
        rethrow;
      }
      throw ExtravioException(
        message: 'Error inesperado. Intenta más tarde.',
      );
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? data['mensaje']?.toString();
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }
}

class ExtravioException implements Exception {
  final String message;
  final int? statusCode;

  ExtravioException({required this.message, this.statusCode});
}
