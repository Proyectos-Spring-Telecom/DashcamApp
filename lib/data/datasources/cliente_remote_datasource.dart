import 'package:dio/dio.dart';
import 'package:dashboardpro/data/models/cliente_model.dart';
import 'package:flutter/foundation.dart';

class ClienteRemoteDataSource {
  final Dio _dio;
  static const String baseUrl = 'https://dashcampay.com/apidev';

  ClienteRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  /// Obtiene la lista de clientes activos (público, sin autenticación)
  /// Endpoint: GET /clientes/public
  /// Retorna únicamente clientes con estatus activo (1)
  Future<List<ClienteModel>> obtenerClientesPublicos() async {
    try {
      debugPrint('📤 Obteniendo clientes públicos activos');
      debugPrint('📤 URL: $baseUrl/clientes/public');
      debugPrint('📤 Método: GET');

      final response = await _dio.get(
        '/clientes/public',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        
        debugPrint('📦 Tipo de respuesta: ${data.runtimeType}');
        debugPrint('📦 Contenido completo: $data');
        
        List<ClienteModel> clientes = [];
        
        if (data is List) {
          debugPrint('📦 La respuesta es una Lista con ${data.length} elementos');
          clientes = (data as List)
              .map((json) {
                try {
                  if (json is! Map<String, dynamic>) {
                    debugPrint('⚠️ Elemento no es un Map: $json');
                    return null;
                  }
                  final cliente = ClienteModel.fromJson(json);
                  debugPrint('✅ Cliente parseado: id=${cliente.id}, nombre=${cliente.nombreCompleto}, estatus=${cliente.estatus}');
                  return cliente;
                } catch (e) {
                  debugPrint('⚠️ Error al parsear cliente: $e, JSON: $json');
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
            debugPrint('⚠️ Cliente ${cliente.id} no está activo (estatus: ${cliente.estatus})');
          }
          return esActivo;
        }).toList();
        } else if (data is Map<String, dynamic>) {
          debugPrint('📦 La respuesta es un Map con keys: ${data.keys}');
          // Si viene como objeto con una lista dentro
          if (data.containsKey('data') && data['data'] is List) {
            final listaData = data['data'] as List;
            debugPrint('📦 Encontrada lista en "data" con ${listaData.length} elementos');
            clientes = listaData
                .map((json) {
                  try {
                    if (json is! Map<String, dynamic>) {
                      debugPrint('⚠️ Elemento no es un Map: $json');
                      return null;
                    }
                    return ClienteModel.fromJson(json);
                  } catch (e) {
                    debugPrint('⚠️ Error al parsear cliente: $e, JSON: $json');
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
            debugPrint('📦 Encontrada lista en "clientes" con ${listaClientes.length} elementos');
            clientes = listaClientes
                .map((json) {
                  try {
                    if (json is! Map<String, dynamic>) {
                      debugPrint('⚠️ Elemento no es un Map: $json');
                      return null;
                    }
                    return ClienteModel.fromJson(json);
                  } catch (e) {
                    debugPrint('⚠️ Error al parsear cliente: $e, JSON: $json');
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
            debugPrint('⚠️ Formato de respuesta no reconocido. Keys: ${data.keys}');
            debugPrint('⚠️ Contenido completo: $data');
            // Intentar parsear como si fuera un solo cliente
            try {
              final cliente = ClienteModel.fromJson(data);
              if (cliente.estatus == null || cliente.isActivo) {
                clientes = [cliente];
              }
            } catch (e) {
              debugPrint('⚠️ No se pudo parsear como cliente único: $e');
            }
            
            if (clientes.isEmpty) {
              throw ClienteException(
                message: 'Formato de respuesta inválido del servidor',
              );
            }
          }
        } else {
          debugPrint('⚠️ Tipo de respuesta no esperado: ${data.runtimeType}');
          throw ClienteException(
            message: 'Formato de respuesta inválido del servidor',
          );
        }
        
        debugPrint('✅ Clientes activos obtenidos: ${clientes.length}');
        if (clientes.isEmpty) {
          debugPrint('⚠️ No se encontraron clientes activos en la respuesta');
          debugPrint('⚠️ Esto puede significar que:');
          debugPrint('   1. No hay clientes activos en el sistema');
          debugPrint('   2. El formato de la respuesta es diferente al esperado');
          debugPrint('   3. El endpoint requiere parámetros adicionales');
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
