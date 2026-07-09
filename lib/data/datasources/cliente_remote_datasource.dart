import 'package:dashboardpro/core/env_config.dart';
import 'package:dashboardpro/interceptors/rate_limit_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/data/models/cliente_model.dart';

class ClienteRemoteDataSource {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  ClienteRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            )..interceptors.add(RateLimitInterceptor());

  /// Obtiene la lista de clientes activos (público, sin autenticación)
  /// Endpoint: GET /clientes/public
  /// Retorna únicamente clientes con estatus activo (1)
  Future<List<ClienteModel>> obtenerClientesPublicos() async {
    try {

      final response = await _dio.get(
        '/clientes/public',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );


      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        
        
        List<ClienteModel> clientes = [];
        
        if (data is List) {
          clientes = (data as List)
              .map((json) {
                try {
                  if (json is! Map<String, dynamic>) {
                    return null;
                  }
                  final cliente = ClienteModel.fromJson(json);
                  return cliente;
                } catch (e) {
                  return null;
                }
              })
              .whereType<ClienteModel>()
              .toList();
              
        // El endpoint /clientes/public ya debería retornar solo activos
        // Pero por si acaso, filtramos: si no tiene estatus, asumir activo
        // Si tiene estatus, solo incluir si es 1 (activo)
        clientes = clientes.where((cliente) {
          final esActivo = cliente.estatus == null || cliente.isActivo;
          if (!esActivo) {
          }
          return esActivo;
        }).toList();
        } else if (data is Map<String, dynamic>) {
          // Si viene como objeto con una lista dentro
          if (data.containsKey('data') && data['data'] is List) {
            final listaData = data['data'] as List;
            clientes = listaData
                .map((json) {
                  try {
                    if (json is! Map<String, dynamic>) {
                      return null;
                    }
                    return ClienteModel.fromJson(json);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<ClienteModel>()
                .toList();
                
            // Filtrar activos
            clientes = clientes.where((cliente) {
              return cliente.estatus == null || cliente.isActivo;
            }).toList();
          } else if (data.containsKey('clientes') && data['clientes'] is List) {
            final listaClientes = data['clientes'] as List;
            clientes = listaClientes
                .map((json) {
                  try {
                    if (json is! Map<String, dynamic>) {
                      return null;
                    }
                    return ClienteModel.fromJson(json);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<ClienteModel>()
                .toList();
                
            // Filtrar activos
            clientes = clientes.where((cliente) {
              return cliente.estatus == null || cliente.isActivo;
            }).toList();
          } else {
            // Intentar parsear como si fuera un solo cliente
            try {
              final cliente = ClienteModel.fromJson(data);
              if (cliente.estatus == null || cliente.isActivo) {
                clientes = [cliente];
              }
            } catch (e) {
            }
            
            if (clientes.isEmpty) {
              throw ClienteException(
                message: 'Formato de respuesta inválido del servidor',
              );
            }
          }
        } else {
          throw ClienteException(
            message: 'Formato de respuesta inválido del servidor',
          );
        }
        
        if (clientes.isEmpty) {
        }
        return clientes;
      }

      throw ClienteException(
        message: 'Error en la respuesta del servidor (código: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final message = _extractMessage(data) ??
          (statusCode == 404
              ? 'Recurso no encontrado. Intenta más tarde.'
              : 'No se pudo obtener la lista de clientes. Intenta más tarde.');

      throw ClienteException(message: message, statusCode: statusCode);
    } catch (e) {
      if (e is ClienteException) {
        rethrow;
      }
      throw ClienteException(
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

class ClienteException implements Exception {
  final String message;
  final int? statusCode;

  ClienteException({required this.message, this.statusCode});
}
