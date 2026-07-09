import 'package:dashboardpro/core/env_config.dart';
import 'package:dashboardpro/utils/secure_log.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/model/monedero/pasajero_wallet_model.dart';
import 'package:dashboardpro/model/monedero/qr_wallet_response.dart';
import 'package:dashboardpro/model/monedero/cliente_model.dart';
import 'package:dashboardpro/model/monedero/pasajero_model.dart';
import 'package:dashboardpro/model/monedero/tipo_pasajero_model.dart';
import 'package:dashboardpro/model/monedero/monedero_request.dart';
import 'package:dashboardpro/model/monedero/monedero_response.dart';
import 'package:dashboardpro/model/monedero/monederos_paginados_response.dart';
import 'package:dashboardpro/model/transaccion/transaccion_response.dart';
import 'package:dashboardpro/model/transaccion/transacciones_response.dart';
import 'package:dashboardpro/model/transaccion/recarga_request.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'dart:convert';

class MonederoService {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl; 

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


      final response = await _dio.get(
        '/monederos/paginados/activos',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: options,
      );


      if (response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final monederosResponse = MonederosPaginadosResponse.fromJson(responseData);
            return monederosResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError) {
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


      final response = await _dio.get(
        '/pasajeros/wallet',
        queryParameters: {'anio': anioParam},
        options: options,
      );


      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": {...} }
          final responseData = response.data as Map<String, dynamic>;
          final data = responseData['data'] as Map<String, dynamic>?;

          if (data == null) {
            throw MonederoException(
                'Error al procesar la respuesta del servidor.');
          }

          final wallet = PasajeroWalletModel.fromJson(data);


          return wallet;
        } catch (parseError) {
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


      // Enviar el body como string JSON para que el backend reciba números y no strings (evita "must be a number")
      final response = await _dio.post(
        '/transacciones/recarga',
        data: jsonBodyString,
        options: options,
      );


      // Aceptar 201 (Created) como respuesta exitosa
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final transaccionResponse = TransaccionResponse.fromJson(responseData);
            return transaccionResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
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
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// Fecha local `YYYY-MM-DD` (mismo criterio que Swagger/curl para filtrar “hoy”).
  static String _fechaHoyIsoLocal() {
    final n = DateTime.now();
    final y = n.year.toString().padLeft(4, '0');
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _resolverFechaRequest(String? f) {
    if (f != null && f.trim().isNotEmpty) return f.trim();
    return _fechaHoyIsoLocal();
  }

  /// Obtiene la lista de transacciones con paginación
  /// Requiere token de autenticación en el header
  /// page: número de página (inicia en 1)
  /// limit: cantidad de registros por página
  /// fechaInicio / fechaFin: "YYYY-MM-DD". Si vienen vacíos o null, se usa el día actual (el backend lo exige).
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

      // ! Fix crítico: nunca enviar null en fechas — el API filtra por rango (comportamiento Swagger).
      final inicio = _resolverFechaRequest(fechaInicio);
      final fin = _resolverFechaRequest(fechaFin);

      // Configurar headers con token de autenticación (Accept alineado a curl / Swagger)
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final options = Options(
        headers: headers,
      );

      final requestBody = <String, dynamic>{
        'page': page,
        'limit': limit,
        'fechaInicio': inicio,
        'fechaFin': fin,
      };

      final jsonBodyString = jsonEncode(requestBody);
      
      if (token != null && token.isNotEmpty) {
        SecureLog.dAuth('📤 Token', present: true);
      } else {
        SecureLog.d('⚠️ ADVERTENCIA: Token es null o vacío');
      }
      

      final response = await _dio.post(
        '/transacciones/paginado',
        data: requestBody,
        options: options,
      );

      
      // Logging detallado de la respuesta completa
      if (response.data is Map) {
        final responseData = Map<String, dynamic>.from(response.data as Map);
        if (responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            if (data.isNotEmpty) {
            }
          } else {
          }
        }
        if (responseData['paginated'] != null) {
        }
      } else {
      }

      // Aceptar 201 (Created) como respuesta exitosa
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          // ! Dio puede entregar Map<dynamic,dynamic>; `is Map<String,dynamic>` falla y no se parseaba.
          final raw = response.data;
          if (raw is! Map) {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
          final responseData = Map<String, dynamic>.from(raw as Map);
          final transaccionesResponse =
              TransaccionesResponse.fromJson(responseData);
          if (transaccionesResponse.data.isEmpty &&
              transaccionesResponse.paginacion.total > 0) {
          }
          return transaccionesResponse;
        } catch (parseError, stackTrace) {
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
      throw MonederoException('Error inesperado: ${e.toString()}');
    }
  }

  /// * UPDATE: Genera el código QR para saldo del monedero con número de pasajes
  /// Requiere token de autenticación en el header
  /// Endpoint: POST /monederos/qr/saldo
  /// Body: { "numeroPasajes": number }
  Future<QrWalletResponse> obtenerQrSaldo(String? token, int numeroPasajes) async {
    try {
      // * IMPORTANT: Validar que numeroPasajes sea válido (> 0)
      if (numeroPasajes <= 0) {
        throw MonederoException('El número de pasajes debe ser mayor a 0.');
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

      // * UPDATE: Preparar body con numeroPasajes
      final requestBody = {
        'numeroPasajes': numeroPasajes,
      };

      if (token != null && token.isNotEmpty) {
        SecureLog.dAuth('📤 Token', present: true);
      } else {
        SecureLog.d('⚠️ ADVERTENCIA: Token es null o vacío');
      }

      // * UPDATE: Cambiar de GET a POST y enviar body
      final response = await _dio.post(
        '/monederos/qr/saldo',
        data: requestBody,
        options: options,
      );


      // * UPDATE: Aceptar 201 (Created) como respuesta exitosa según especificación
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final qrResponse = QrWalletResponse.fromJson(responseData);
            return qrResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
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


        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al obtener el código QR';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        // * ERROR HANDLING: Manejo específico de códigos de estado según especificación
        if (statusCode == 401 || statusCode == 403) {
          throw MonederoException(
              'Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 404) {
          throw MonederoException('Pasajero o monedero no encontrado.');
        } else if (statusCode == 500) {
          throw MonederoException(
              'Error del servidor. Intenta más tarde.');
        } else {
          throw MonederoException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Error al generar el código QR.');
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


      final response = await _dio.get(
        '/clientes/list',
        options: options,
      );


      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": [...] }
          final responseData = response.data as Map<String, dynamic>;
          final dataList = responseData['data'] as List<dynamic>?;

          if (dataList == null) {
            return [];
          }

          final clientes = dataList
              .map((item) => ClienteModel.fromJson(item as Map<String, dynamic>))
              .toList();

          return clientes;
        } catch (parseError) {
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


      final response = await _dio.get(
        '/pasajeros/list',
        options: options,
      );


      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": [...] }
          final responseData = response.data as Map<String, dynamic>;
          final dataList = responseData['data'] as List<dynamic>?;

          if (dataList == null) {
            return [];
          }

          final pasajeros = dataList
              .map((item) => PasajeroModel.fromJson(item as Map<String, dynamic>))
              .toList();

          return pasajeros;
        } catch (parseError) {
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


      final response = await _dio.get(
        '/catpasajero/list',
        options: options,
      );


      if (response.statusCode == 200) {
        try {
          // La respuesta tiene estructura { "data": [...] }
          final responseData = response.data as Map<String, dynamic>;
          final dataList = responseData['data'] as List<dynamic>?;

          if (dataList == null) {
            return [];
          }

          final tiposPasajero = dataList
              .map((item) => TipoPasajeroModel.fromJson(item as Map<String, dynamic>))
              .toList();

          return tiposPasajero;
        } catch (parseError) {
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


      final response = await _dio.post(
        '/monederos',
        data: requestBody,
        options: options,
      );


      // Aceptar 201 (Created) o 200 como respuesta exitosa
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            final monederoResponse = MonederoResponse.fromJson(responseData);
            return monederoResponse;
          } else {
            throw MonederoException(
                'Error al procesar la respuesta del servidor: formato de respuesta inválido.');
          }
        } catch (parseError, stackTrace) {
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

