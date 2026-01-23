import 'package:dio/dio.dart';
import 'package:dashboardpro/model/monedero/monedero_model.dart';
import 'package:dashboardpro/model/monedero/pasajero_wallet_model.dart';
import 'package:dashboardpro/model/monedero/qr_wallet_response.dart';
import 'package:dashboardpro/model/monedero/cliente_model.dart';
import 'package:dashboardpro/model/monedero/pasajero_model.dart';
import 'package:dashboardpro/model/monedero/tipo_pasajero_model.dart';
import 'package:dashboardpro/model/monedero/monedero_request.dart';
import 'package:dashboardpro/model/monedero/monedero_response.dart';
import 'package:dashboardpro/model/monedero/monederos_paginados_response.dart';
import 'package:dashboardpro/model/transaccion/transaccion_request.dart';
import 'package:dashboardpro/model/transaccion/transaccion_response.dart';
import 'package:dashboardpro/model/transaccion/transacciones_response.dart';
import 'package:dashboardpro/model/transaccion/recarga_request.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class MonederoService {
  final Dio _dio;
  static const String baseUrl = 'https://dashcampay.com/apidev'; 

  MonederoService({Dio? dio})
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

  /// Obtiene la lista de monederos activos paginados
  /// Requiere token de autenticación en el header
  /// Endpoint: GET /monederos/paginados/activos?page=1&limit=20
  Future<MonederosPaginadosResponse> obtenerListaMonederos(
    String? token, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Configurar headers con token de autenticación
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      debugPrint('📤 Obteniendo lista de monederos activos paginados');
      debugPrint('📤 URL: $baseUrl/monederos/paginados/activos?page=$page&limit=$limit');
      debugPrint('📤 Método: GET');
      debugPrint('📤 Page: $page, Limit: $limit');

      final response = await _dio.get(
        '/monederos/paginados/activos',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final monederosResponse = MonederosPaginadosResponse.fromJson(responseData);
            debugPrint('✅ Monederos obtenidos: ${monederosResponse.data.length}');
            debugPrint('✅ Paginación: página ${monederosResponse.paginacion.page}/${monederosResponse.paginacion.lastPage} (total: ${monederosResponse.paginacion.total})');
            return monederosResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          throw MonederoException(
              'Error al procesar la respuesta del servidor.');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN OBTENER MONEDEROS ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener la lista de monederos';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'No se pudo obtener la información. Intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener la lista de monederos.');
        }
      } else {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo obtener la información. Intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en obtenerListaMonederos: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene la información del wallet del pasajero logueado
  /// Requiere token de autenticación en el header
  /// Endpoint: GET /pasajeros/wallet?anio=YYYY
  /// [anio] es opcional, si no se proporciona se usa el año actual
  Future<PasajeroWalletModel> obtenerWallet(String? token, {int? anio}) async {
    try {
      // Si no se proporciona el año, usar el año actual
      final anioParam = anio ?? DateTime.now().year;

      // Configurar headers con token de autenticación
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      debugPrint('📤 Obteniendo información del wallet');
      debugPrint('📤 URL: $baseUrl/pasajeros/wallet?anio=$anioParam');
      debugPrint('📤 Método: GET');
      debugPrint('📤 Año: $anioParam');

      final response = await _dio.get(
        '/pasajeros/wallet',
        queryParameters: {'anio': anioParam},
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": {...} }
          final responseData = response.data as Map<String, dynamic>;
          final data = responseData['data'] as Map<String, dynamic>?;

          if (data == null) {
            debugPrint('⚠️ La respuesta no contiene el campo "data"');
            throw MonederoException(
                'Error al procesar la respuesta del servidor.');
          }

          final wallet = PasajeroWalletModel.fromJson(data);

          debugPrint('✅ Wallet obtenido exitosamente');
          debugPrint('✅ Saldo Total: ${wallet.saldoTotal}');
          debugPrint('✅ Monederos: ${wallet.monederos}');

          return wallet;
        } catch (parseError) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          throw MonederoException(
              'Error al procesar la respuesta del servidor.');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN OBTENER WALLET ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener la información del wallet';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'No se pudo obtener la información. Intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener la información del wallet.');
        }
      } else {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo obtener la información. Intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en obtenerWallet: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Realiza una recarga a un monedero
  /// Requiere token de autenticación en el header
  /// Endpoint: POST /transacciones/recarga
  Future<TransaccionResponse> realizarRecarga(
    RecargaRequest request,
    String? token,
  ) async {
    try {
      // Validaciones previas
      if (request.numeroSerieMonedero.isEmpty) {
        throw MonederoException('El número de serie del monedero no es válido.');
      }

      if (request.monto <= 0) {
        throw MonederoException('El monto debe ser mayor a 0.');
      }

      if (request.idTipoTransaccion <= 0) {
        throw MonederoException('El ID del tipo de transacción no es válido.');
      }

      // Configurar headers con token de autenticación
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final options = Options(
        headers: headers,
      );

      final requestBody = request.toJson();
      final jsonBodyString = jsonEncode(requestBody);

      debugPrint('📤 Realizando recarga a monedero');
      debugPrint('📤 URL: $baseUrl/transacciones/recarga');
      debugPrint('📤 Método: POST');
      debugPrint('📤 Request Body (JSON): $jsonBodyString');

      final response = await _dio.post(
        '/transacciones/recarga',
        data: requestBody,
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      // Aceptar 201 (Created) como respuesta exitosa
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final transaccionResponse = TransaccionResponse.fromJson(responseData);
            debugPrint('✅ Recarga realizada exitosamente');
            debugPrint('✅ ID Transacción: ${transaccionResponse.data.id}');
            debugPrint('✅ Mensaje: ${transaccionResponse.message}');
            return transaccionResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          debugPrint('❌ Stack trace: $stackTrace');
          throw MonederoException(
              'Error al procesar la respuesta del servidor: ${parseError.toString()}');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo realizar el cargo, intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo realizar el cargo, intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN REALIZAR CARGO ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al realizar el cargo';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 400) {
          // Mensajes específicos según el tipo de error
          if (errorMessage.toLowerCase().contains('saldo') ||
              errorMessage.toLowerCase().contains('insuficiente')) {
            throw MonederoException('Saldo insuficiente');
          } else if (errorMessage.toLowerCase().contains('inválid') ||
              errorMessage.toLowerCase().contains('invalid')) {
            throw MonederoException('Datos inválidos. Verifica la información ingresada.');
          } else {
            throw MonederoException(
                errorMessage.isNotEmpty ? errorMessage : 'Datos inválidos');
          }
        } else if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'No se pudo realizar el cargo, intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al realizar el cargo.');
        }
      } else {
        throw MonederoException(
            'No se pudo realizar el cargo, intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo realizar el cargo, intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en realizarCargo: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene la lista de transacciones con paginación
  /// Requiere token de autenticación en el header
  /// page: número de página (inicia en 1)
  /// limit: cantidad de registros por página
  /// fechaInicio: fecha de inicio para filtrar (formato: "YYYY-MM-DD") - opcional
  /// fechaFin: fecha de fin para filtrar (formato: "YYYY-MM-DD") - opcional
  Future<TransaccionesResponse> obtenerListaTransacciones({
    required String? token,
    required int page,
    required int limit,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      // Validaciones
      if (page < 1) {
        throw MonederoException('El número de página debe ser mayor a 0.');
      }
      if (limit < 1) {
        throw MonederoException('El límite debe ser mayor a 0.');
      }

      // Configurar headers con token de autenticación
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final options = Options(
        headers: headers,
      );

      // Preparar el body exactamente como Postman lo envía
      // Incluir fechaInicio y fechaFin si se proporcionan, de lo contrario null
      final requestBody = {
        'page': page,
        'limit': limit,
        'fechaInicio': fechaInicio, // Puede ser null o un string con formato "YYYY-MM-DD"
        'fechaFin': fechaFin, // Puede ser null o un string con formato "YYYY-MM-DD"
      };

      // Serializar a JSON para ver exactamente qué se envía
      final jsonBodyString = jsonEncode(requestBody);
      
      debugPrint('📤 Obteniendo lista de transacciones (paginado)');
      debugPrint('📤 URL: $baseUrl/transacciones/paginado');
      debugPrint('📤 Método: POST');
      debugPrint('📤 Request Body (JSON): $jsonBodyString');
      debugPrint('📤 Headers enviados: $headers');
      if (token != null && token.isNotEmpty) {
        debugPrint('📤 Token (primeros 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
        debugPrint('📤 Token (últimos 10 chars): ...${token.substring(token.length > 10 ? token.length - 10 : 0)}');
      } else {
        debugPrint('⚠️ ADVERTENCIA: Token es null o vacío');
      }
      
      // Log adicional para diagnóstico
      debugPrint('📤 Parámetros: page=$page, limit=$limit, fechaInicio=$fechaInicio, fechaFin=$fechaFin');

      // Dio serializará el Map automáticamente a JSON
      final response = await _dio.post(
        '/transacciones/paginado',
        data: requestBody,
        options: options,
      );

      debugPrint('📥 Status Code: ${response.statusCode}');
      
      // Logging detallado de la respuesta completa
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        debugPrint('📦 Respuesta completa recibida:');
        debugPrint('📦 Keys: ${responseData.keys.toList()}');
        if (responseData['data'] != null) {
          final data = responseData['data'];
          debugPrint('📦 data es List: ${data is List}');
          if (data is List) {
            debugPrint('📦 Cantidad de items en data: ${data.length}');
            if (data.isNotEmpty) {
              debugPrint('📦 Primer item: ${data.first}');
            }
          } else {
            debugPrint('📦 Tipo de data: ${data.runtimeType}');
            debugPrint('📦 Valor de data: $data');
          }
        }
        if (responseData['paginated'] != null) {
          debugPrint('📦 paginated: ${responseData['paginated']}');
        }
      } else {
        debugPrint('📦 Tipo de respuesta: ${response.data.runtimeType}');
        debugPrint('📦 Respuesta completa: ${response.data}');
      }

      // Aceptar 201 (Created) como respuesta exitosa
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final transaccionesResponse =
                TransaccionesResponse.fromJson(responseData);
            debugPrint('✅ Transacciones parseadas: ${transaccionesResponse.data.length}');
            debugPrint('✅ Paginación: página ${transaccionesResponse.paginacion.page}/${transaccionesResponse.paginacion.lastPage} (total: ${transaccionesResponse.paginacion.total})');
            if (transaccionesResponse.data.isEmpty && transaccionesResponse.paginacion.total > 0) {
              debugPrint('⚠️ ADVERTENCIA: total > 0 pero lista vacía. Posible error en parseo.');
            }
            return transaccionesResponse;
          } else {
            debugPrint('❌ La respuesta no es un Map, es: ${response.data.runtimeType}');
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          debugPrint('❌ Stack trace: $stackTrace');
          throw MonederoException(
              'Error al procesar la respuesta del servidor: ${parseError.toString()}');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN OBTENER TRANSACCIONES ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener la lista de transacciones';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData['errors']?.toString() ??
              errorMessage;
          
          // Si el mensaje contiene información sobre rol, mejorar el mensaje
          if (errorMessage.toLowerCase().contains('rol') || 
              errorMessage.toLowerCase().contains('role') ||
              errorMessage.toLowerCase().contains('permiso')) {
            debugPrint('⚠️ Error relacionado con rol o permisos detectado');
            debugPrint('⚠️ Mensaje completo del servidor: $errorMessage');
            // No cambiar el mensaje, dejarlo tal como viene del servidor para diagnóstico
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        // Manejar diferentes códigos de estado HTTP
        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida o sin permisos. Por favor, verifica tu sesión o contacta al administrador.');
        } else if (statusCode == 404) {
          throw MonederoException('No se encontraron transacciones.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'Error del servidor. Intenta más tarde o contacta al soporte.');
        } else {
          // Para otros errores, mostrar el mensaje del servidor si está disponible
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener la lista de transacciones (código: $statusCode).');
        }
      } else {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo obtener la información. Intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en obtenerListaTransacciones: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene el código QR para saldo del monedero
  /// Requiere token de autenticación en el header
  /// Endpoint: GET /monederos/qr/saldo
  Future<QrWalletResponse> obtenerQrSaldo(String? token) async {
    try {
      // Configurar headers con token de autenticación
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final options = Options(
        headers: headers,
      );

      debugPrint('📤 Obteniendo código QR para saldo');
      debugPrint('📤 URL: $baseUrl/monederos/qr/saldo');
      debugPrint('📤 Método: GET');
      if (token != null && token.isNotEmpty) {
        debugPrint('📤 Token (primeros 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
      } else {
        debugPrint('⚠️ ADVERTENCIA: Token es null o vacío');
      }

      final response = await _dio.get(
        '/monederos/qr/saldo',
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      // Aceptar 200 (OK) como respuesta exitosa
      if (response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final qrResponse = QrWalletResponse.fromJson(responseData);
            debugPrint('✅ QR obtenido exitosamente');
            debugPrint('✅ ID QR: ${qrResponse.data.idQR}');
            debugPrint('✅ Saldo: ${qrResponse.data.saldo}');
            debugPrint('✅ Número de Serie: ${qrResponse.data.numeroSerie}');
            debugPrint('✅ QR Code (primeros 50 chars): ${qrResponse.data.qrCode.substring(0, qrResponse.data.qrCode.length > 50 ? 50 : qrResponse.data.qrCode.length)}...');
            return qrResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          debugPrint('❌ Stack trace: $stackTrace');
          throw MonederoException(
              'Error al procesar la respuesta del servidor: ${parseError.toString()}');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'Tiempo de espera agotado. Verifica tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'Error de conexión. Verifica tu conexión a internet.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN OBTENER QR ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ =========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener el código QR';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 404) {
          throw MonederoException('No se pudo generar el código QR.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'Error del servidor. Intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener el código QR.');
        }
      } else {
        throw MonederoException(
            'Error de conexión. Verifica tu conexión a internet.');
      }
    } on SocketException {
      throw MonederoException(
          'Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en obtenerQrSaldo: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene la lista de clientes disponibles
  /// Requiere token de autenticación en el header
  Future<List<ClienteModel>> obtenerListaClientes(String? token) async {
    try {
      // Configurar headers con token de autenticación
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      debugPrint('📤 Obteniendo lista de clientes');
      debugPrint('📤 URL: $baseUrl/clientes/list');
      debugPrint('📤 Método: GET');

      final response = await _dio.get(
        '/clientes/list',
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": [...] }
          final responseData = response.data as Map<String, dynamic>;
          final dataList = responseData['data'] as List<dynamic>?;

          if (dataList == null) {
            debugPrint('⚠️ La respuesta no contiene el campo "data"');
            return [];
          }

          final clientes = dataList
              .map((item) => ClienteModel.fromJson(item as Map<String, dynamic>))
              .toList();

          debugPrint('✅ Clientes obtenidos: ${clientes.length}');
          return clientes;
        } catch (parseError) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          throw MonederoException(
              'Error al procesar la respuesta del servidor.');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN OBTENER CLIENTES ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener la lista de clientes';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'No se pudo obtener la información. Intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener la lista de clientes.');
        }
      } else {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo obtener la información. Intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en obtenerListaClientes: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene la lista de pasajeros disponibles
  /// Requiere token de autenticación en el header
  Future<List<PasajeroModel>> obtenerListaPasajeros(String? token) async {
    try {
      // Configurar headers con token de autenticación
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      debugPrint('📤 Obteniendo lista de pasajeros');
      debugPrint('📤 URL: $baseUrl/pasajeros/list');
      debugPrint('📤 Método: GET');

      final response = await _dio.get(
        '/pasajeros/list',
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": [...] }
          final responseData = response.data as Map<String, dynamic>;
          final dataList = responseData['data'] as List<dynamic>?;

          if (dataList == null) {
            debugPrint('⚠️ La respuesta no contiene el campo "data"');
            return [];
          }

          final pasajeros = dataList
              .map((item) => PasajeroModel.fromJson(item as Map<String, dynamic>))
              .toList();

          debugPrint('✅ Pasajeros obtenidos: ${pasajeros.length}');
          return pasajeros;
        } catch (parseError) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          throw MonederoException(
              'Error al procesar la respuesta del servidor.');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN OBTENER PASAJEROS ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener la lista de pasajeros';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'No se pudo obtener la información. Intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener la lista de pasajeros.');
        }
      } else {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo obtener la información. Intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en obtenerListaPasajeros: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene la lista de tipos de pasajero disponibles
  /// Requiere token de autenticación en el header
  /// La respuesta del servidor ya viene filtrada por el idCliente del usuario
  Future<List<TipoPasajeroModel>> obtenerListaTiposPasajero(String? token) async {
    try {
      // Configurar headers con token de autenticación
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      debugPrint('📤 Obteniendo lista de tipos de pasajero');
      debugPrint('📤 URL: $baseUrl/catpasajero/list');
      debugPrint('📤 Método: GET');

      final response = await _dio.get(
        '/catpasajero/list',
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": [...] }
          final responseData = response.data as Map<String, dynamic>;
          final dataList = responseData['data'] as List<dynamic>?;

          if (dataList == null) {
            debugPrint('⚠️ La respuesta no contiene el campo "data"');
            return [];
          }

          final tiposPasajero = dataList
              .map((item) => TipoPasajeroModel.fromJson(item as Map<String, dynamic>))
              .toList();

          debugPrint('✅ Tipos de pasajero obtenidos: ${tiposPasajero.length}');
          return tiposPasajero;
        } catch (parseError) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          throw MonederoException(
              'Error al procesar la respuesta del servidor.');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN OBTENER TIPOS PASAJERO ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener la lista de tipos de pasajero';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'No se pudo obtener la información. Intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al obtener la lista de tipos de pasajero.');
        }
      } else {
        throw MonederoException(
            'No se pudo obtener la información. Intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo obtener la información. Intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en obtenerListaTiposPasajero: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Crea un nuevo monedero
  /// Requiere token de autenticación en el header
  Future<MonederoResponse> crearMonedero(MonederoRequest request, String? token) async {
    try {
      // Validaciones previas
      if (request.numeroSerie.trim().isEmpty) {
        throw MonederoException('El número de serie no puede estar vacío.');
      }

      if (request.saldo < 0) {
        throw MonederoException('El saldo debe ser mayor o igual a 0.');
      }

      // idPasajero es opcional, solo validar si se proporciona
      if (request.idPasajero != null && request.idPasajero! <= 0) {
        throw MonederoException('El ID del pasajero no es válido.');
      }

      if (request.idCliente <= 0) {
        throw MonederoException('El ID del cliente no es válido.');
      }

      if (request.idTipoPasajero <= 0) {
        throw MonederoException('El ID del tipo de pasajero no es válido.');
      }

      if (request.idCard.trim().isEmpty) {
        throw MonederoException('El ID de la tarjeta no puede estar vacío.');
      }

      // Configurar headers con token de autenticación
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final options = Options(
        headers: headers,
      );

      final requestBody = request.toJson();
      final jsonBodyString = jsonEncode(requestBody);

      debugPrint('📤 Creando nuevo monedero');
      debugPrint('📤 URL: $baseUrl/monederos');
      debugPrint('📤 Método: POST');
      debugPrint('📤 Request Body (JSON): $jsonBodyString');

      final response = await _dio.post(
        '/monederos',
        data: requestBody,
        options: options,
      );

      debugPrint('📥 Status Code recibido: ${response.statusCode}');
      debugPrint('📥 Datos recibidos: ${response.data}');

      // Aceptar 201 (Created) o 200 como respuesta exitosa
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final monederoResponse = MonederoResponse.fromJson(responseData);
            debugPrint('✅ Monedero creado exitosamente');
            debugPrint('✅ ID Monedero: ${monederoResponse.data.id}');
            debugPrint('✅ Mensaje: ${monederoResponse.message}');
            return monederoResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
          debugPrint('❌ Error al parsear respuesta: $parseError');
          debugPrint('❌ Stack trace: $stackTrace');
          throw MonederoException(
              'Error al procesar la respuesta del servidor: ${parseError.toString()}');
        }
      } else {
        throw MonederoException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MonederoException(
            'No se pudo crear el monedero, intenta más tarde.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw MonederoException(
            'No se pudo crear el monedero, intenta más tarde.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        debugPrint('❌ ========== ERROR EN CREAR MONEDERO ==========');
        debugPrint('❌ Status Code: $statusCode');
        debugPrint('❌ Tipo de respuesta: ${responseData.runtimeType}');
        debugPrint('❌ Datos de respuesta: $responseData');
        debugPrint('❌ ===========================================');

        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al crear el monedero';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 400) {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Datos inválidos. Verifica la información ingresada.');
        } else if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'No se pudo crear el monedero, intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al crear el monedero.');
        }
      } else {
        throw MonederoException(
            'No se pudo crear el monedero, intenta más tarde.');
      }
    } on SocketException {
      throw MonederoException(
          'No se pudo crear el monedero, intenta más tarde.');
    } catch (e) {
      if (e is MonederoException) {
        rethrow;
      }
      debugPrint('❌ Error inesperado en crearMonedero: $e');
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }
}

/// Excepción personalizada para errores relacionados con monederos
class MonederoException implements Exception {
  final String message;

  MonederoException(this.message);

  @override
  String toString() => message;
}

