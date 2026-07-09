import 'package:dashboardpro/core/env_config.dart';
import 'package:dashboardpro/utils/secure_log.dart';
import 'package:dio/dio.dart';
import 'package:dashboardpro/model/netpay/netpay_customer_model.dart';
import 'package:dashboardpro/model/netpay/assign_card_token_request.dart';
import 'package:dashboardpro/model/netpay/create_customer_request.dart';
import 'package:dashboardpro/model/netpay/create_customer_response.dart';
import 'package:dashboardpro/interceptors/session_interceptor.dart';
import 'dart:io';
import 'dart:convert';

class NetPayException implements Exception {
  final String message;
  NetPayException(this.message);

  @override
  String toString() => message;
}

class NetPayService {
  final Dio _dio;
  static String get baseUrl => EnvConfig.apiBaseUrl;

  NetPayService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            )..interceptors.add(SessionInterceptor());

  /// Consulta la información de un cliente de NetPay y sus tarjetas registradas
  /// Endpoint: GET /netpay/customers?customerId={customerId}
  /// [customerId] es el ID del cliente en NetPay
  /// [token] es el token de autenticación del usuario logueado
  Future<NetPayCustomerModel> obtenerClienteNetPay({
    required String customerId,
    required String? token,
  }) async {
    try {
      // Validar que se proporcionó el customerId
      if (customerId.isEmpty) {
        throw NetPayException('El ID del cliente es requerido.');
      }

      if (token == null || token.isEmpty) {
        throw NetPayException('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      // Configurar headers con token de autenticación
      final options = Options(
        headers: {'Authorization': 'Bearer $token'},
      );

      
      // Construir la URL completa para verificar
      final fullUrl = '$baseUrl/netpay/customers?customerId=${Uri.encodeComponent(customerId)}';
      
      // Asegurar que el customerId esté limpio (sin espacios al inicio/final)
      final cleanCustomerId = customerId.trim();

      // Usar queryParameters - Dio debería hacer el encoding automáticamente
      // Pero también podemos verificar que se esté enviando correctamente
      final response = await _dio.get(
        '/netpay/customers',
        queryParameters: {'customerId': cleanCustomerId},
        options: options,
      );
      
      // Loggear la URL real que se construyó (disponible en requestOptions)

      
      // Solo loggear una muestra de los datos para no saturar los logs
      if (response.data is Map) {
        final data = response.data as Map;
        if (data.containsKey('paymentSources')) {
        }
        if (data.containsKey('id')) {
        }
      } else if (response.data is String) {
      } else {
      }

      if (response.statusCode == 200) {
        try {
          // Verificar que la respuesta sea un Map
          if (response.data is! Map<String, dynamic>) {
            throw NetPayException('El servidor respondió con un formato inesperado.');
          }
          
          final customerData = response.data as Map<String, dynamic>;
          
          // Debug: imprimir estructura completa de la respuesta
          
          // Verificar si existe el arreglo datosTarjeta
          if (customerData.containsKey('datosTarjeta') && customerData['datosTarjeta'] is List) {
            final datosTarjeta = customerData['datosTarjeta'] as List;
            for (var i = 0; i < datosTarjeta.length && i < 3; i++) {
              final dt = datosTarjeta[i] as Map<String, dynamic>;
              if (dt.containsKey('tokenCard')) {
                SecureLog.dToken('     - tokenCard', dt['tokenCard']?.toString());
              }
              if (dt.containsKey('idDireccion')) {
              } else {
              }
            }
          } else {
          }
          
          // Debug: imprimir estructura de paymentSources para verificar deviceFingerPrint e idDireccion
          if (customerData.containsKey('paymentSources') && customerData['paymentSources'] is List) {
            final paymentSources = customerData['paymentSources'] as List;
            for (var i = 0; i < paymentSources.length && i < 3; i++) {
              final ps = paymentSources[i] as Map<String, dynamic>;
              if (ps.containsKey('deviceFingerPrint')) {
              } else {
              }
              // Verificar idDireccion en el nivel de paymentSource
              if (ps.containsKey('idDireccion')) {
              } else {
              }
              if (ps.containsKey('card') && ps['card'] is Map) {
                final card = ps['card'] as Map<String, dynamic>;
                SecureLog.dToken('     - card.token', card['token']?.toString());
                if (card.containsKey('idDireccion')) {
                } else {
                }
              }
            }
          }
          
          final customer = NetPayCustomerModel.fromJson(customerData);


          return customer;
        } catch (parseError) {
          throw NetPayException('Error al procesar la respuesta del servidor.');
        }
      } else {
        throw NetPayException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetPayException(
            'Tiempo de espera agotado. Revisa tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (e.requestOptions.headers.containsKey('Authorization')) {
          final authHeader = e.requestOptions.headers['Authorization']?.toString() ?? '';
        }

        // Intentar extraer mensaje de error del servidor primero
        String errorMessage = 'Error al obtener información del cliente NetPay.';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData['detail']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        // Manejar errores específicos
        if (statusCode == 404) {
          throw NetPayException(errorMessage.isNotEmpty && errorMessage != 'Error al obtener información del cliente NetPay.'
              ? errorMessage
              : 'Cliente no encontrado en NetPay.');
        } else if (statusCode == 401 || statusCode == 403) {
          throw NetPayException('Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw NetPayException(errorMessage.isNotEmpty && errorMessage != 'Error al obtener información del cliente NetPay.'
              ? errorMessage
              : 'Error en el servidor. Intenta más tarde.');
        } else {
          throw NetPayException(errorMessage);
        }
      } else {
        throw NetPayException(
            'Error de conexión. Revisa tu conexión a internet.');
      }
    } on SocketException {
      throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
    } catch (e) {
      if (e is NetPayException) {
        rethrow;
      }
      
      // Proporcionar mensajes más específicos según el tipo de error
      if (e is FormatException) {
        throw NetPayException('Error al procesar la respuesta del servidor. Por favor, intenta nuevamente.');
      } else if (e is TypeError) {
        throw NetPayException('Error en el formato de datos recibidos. Por favor, intenta nuevamente.');
      } else {
        throw NetPayException('Error al obtener los métodos de pago. Por favor, verifica tu conexión e intenta nuevamente.');
      }
    }
  }

  /// Asigna un token de tarjeta a un cliente NetPay
  /// Crea un nuevo cliente en NetPay
  /// Endpoint: POST /netpay/customers
  /// [request] contiene los datos del cliente y el token de la tarjeta
  /// [token] es el token de autenticación del usuario logueado
  /// Retorna el customerId del cliente creado
  Future<CreateCustomerResponse> crearClienteNetPay({
    required CreateCustomerRequest request,
    required String? token,
  }) async {
    try {
      // Validaciones previas
      if (request.firstName.isEmpty) {
        throw NetPayException('El nombre es requerido.');
      }

      if (request.lastName.isEmpty) {
        throw NetPayException('El apellido es requerido.');
      }

      if (request.email.isEmpty) {
        throw NetPayException('El correo electrónico es requerido.');
      }

      if (request.phone.isEmpty) {
        throw NetPayException('El teléfono es requerido.');
      }

      if (request.token.isEmpty) {
        throw NetPayException('El token de la tarjeta es requerido.');
      }

      if (token == null || token.isEmpty) {
        throw NetPayException('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      // Configurar headers con token de autenticación
      final options = Options(
        headers: {'Authorization': 'Bearer $token'},
      );

      final requestBody = request.toJson();


      final response = await _dio.post(
        '/netpay/customers',
        data: requestBody,
        options: options,
      );


      if (response.statusCode == 201) {
        try {
          final responseData = response.data;
          CreateCustomerResponse customerResponse;

          // La respuesta puede venir en diferentes formatos
          if (responseData is Map<String, dynamic>) {
            // Si viene directamente el objeto
            if (responseData.containsKey('customerId') || responseData.containsKey('id')) {
              customerResponse = CreateCustomerResponse.fromJson(responseData);
            } else if (responseData.containsKey('data')) {
              // Si viene dentro de un objeto "data"
              customerResponse = CreateCustomerResponse.fromJson(responseData['data'] as Map<String, dynamic>);
            } else {
              // Intentar parsear como CreateCustomerResponse directamente
              customerResponse = CreateCustomerResponse.fromJson(responseData);
            }
          } else {
            throw NetPayException('Formato de respuesta inesperado del servidor.');
          }


          return customerResponse;
        } catch (e) {
          throw NetPayException('Error al procesar la respuesta del servidor.');
        }
      } else {
        throw NetPayException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetPayException(
            'Tiempo de espera agotado. Revisa tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;


        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al crear el cliente';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData['errors']?.toString() ??
              responseData['detail']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 400) {
          throw NetPayException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Datos inválidos. Verifica la información ingresada.');
        } else if (statusCode == 401 || statusCode == 403) {
          throw NetPayException('Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw NetPayException('Error en el servidor. Intenta más tarde.');
        } else {
          throw NetPayException(errorMessage);
        }
      } else {
        throw NetPayException(
            'Error de conexión. Revisa tu conexión a internet.');
      }
    } on SocketException {
      throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
    } catch (e) {
      if (e is NetPayException) {
        rethrow;
      }
      throw NetPayException('Error inesperado: ${e.toString()}');
    }
  }

  /// Sanitiza el request body para logging (elimina datos sensibles)
  String _sanitizeCreateCustomerRequestForLogging(Map<String, dynamic> requestBody) {
    final sanitized = Map<String, dynamic>.from(requestBody);
    if (sanitized.containsKey('token')) {
      sanitized['token'] = '***TOKEN_OCULTO***';
    }
    return sanitized.toString();
  }

  /// Endpoint: PUT /netpay/customers/{customerId}/token
  /// [customerId] es el ID del cliente en NetPay
  /// [request] contiene los datos del token y la información del cliente
  /// [token] es el token de autenticación del usuario logueado
  Future<void> asignarTokenTarjeta({
    required String customerId,
    required AssignCardTokenRequest request,
    required String? token,
  }) async {
    try {
      // Validaciones previas
      if (customerId.isEmpty) {
        throw NetPayException('El ID del cliente es requerido.');
      }

      if (request.token.isEmpty) {
        throw NetPayException('El token de la tarjeta es requerido.');
      }

      if (token == null || token.isEmpty) {
        throw NetPayException('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      // Configurar headers con token de autenticación
      final options = Options(
        headers: {'Authorization': 'Bearer $token'},
      );

      final requestBody = request.toJson();


      final response = await _dio.put(
        '/netpay/customers/$customerId/token',
        data: requestBody,
        options: options,
      );

      
      // No loggear el response completo por seguridad, solo confirmar éxito
      if (response.statusCode == 200) {
      } else {
        throw NetPayException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetPayException(
            'Tiempo de espera agotado. Revisa tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;


        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al asignar la tarjeta';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData['errors']?.toString() ??
              responseData['detail']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 400) {
          // Si el error menciona un 504 de NetPay, mejorar el mensaje
          if (errorMessage.contains('504') || errorMessage.contains('Netpay')) {
            throw NetPayException('El servicio de pagos no está disponible en este momento. Por favor, intenta nuevamente más tarde.');
          }
          throw NetPayException(errorMessage.isNotEmpty
              ? errorMessage
              : 'Datos inválidos. Verifica la información ingresada.');
        } else if (statusCode == 401 || statusCode == 403) {
          throw NetPayException('Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 404) {
          throw NetPayException('Cliente no encontrado en NetPay.');
        } else if (statusCode == 500) {
          throw NetPayException('Error en el servidor. Intenta más tarde.');
        } else {
          throw NetPayException(errorMessage);
        }
      } else {
        throw NetPayException(
            'Error de conexión. Revisa tu conexión a internet.');
      }
    } on SocketException {
      throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
    } catch (e) {
      if (e is NetPayException) {
        rethrow;
      }
      throw NetPayException('Error inesperado: ${e.toString()}');
    }
  }

  /// Sanitiza el request body para logging (elimina datos sensibles)
  String _sanitizeRequestForLogging(Map<String, dynamic> requestBody) {
    final sanitized = Map<String, dynamic>.from(requestBody);
    
    // No mostrar el token completo, solo primeros y últimos caracteres
    if (sanitized['token'] != null) {
      final token = sanitized['token'] as String;
      if (token.length > 10) {
        sanitized['token'] = '${token.substring(0, 5)}...${token.substring(token.length - 5)}';
      } else {
        sanitized['token'] = '***';
      }
    }
    
    // No mostrar CVV
    if (sanitized['cvv2'] != null) {
      sanitized['cvv2'] = '***';
    }
    
    return jsonEncode(sanitized);
  }

  /// Elimina una tarjeta de un cliente NetPay
  /// Endpoint: DELETE /netpay/customers/{customerId}/cards/{tokenCard}
  /// [customerId] es el ID del cliente en NetPay
  /// [tokenCard] es el token de la tarjeta a eliminar
  /// [token] es el token de autenticación del usuario logueado
  Future<void> eliminarTarjeta({
    required String customerId,
    required String tokenCard,
    required String? token,
  }) async {
    try {
      // Validaciones previas
      if (customerId.isEmpty) {
        throw NetPayException('El ID del cliente es requerido.');
      }

      if (tokenCard.isEmpty) {
        throw NetPayException('El token de la tarjeta es requerido.');
      }

      if (token == null || token.isEmpty) {
        throw NetPayException('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      // Configurar headers con token de autenticación
      final options = Options(
        headers: {'Authorization': 'Bearer $token'},
      );

      SecureLog.dToken('📤 Token de tarjeta', tokenCard);

      final response = await _dio.delete(
        '/netpay/customers/$customerId/cards/$tokenCard',
        options: options,
      );

      
      if (response.statusCode == 200) {
      } else {
        throw NetPayException(
            'Error en la respuesta del servidor (código: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetPayException(
            'Tiempo de espera agotado. Revisa tu conexión a internet.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;


        // Intentar extraer mensaje de error del servidor
        String errorMessage = 'Error al eliminar la tarjeta';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData['errors']?.toString() ??
              responseData['detail']?.toString() ??
              errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        if (statusCode == 404) {
          throw NetPayException('Tarjeta no encontrada.');
        } else if (statusCode == 401 || statusCode == 403) {
          throw NetPayException('Sesión inválida. Por favor, inicia sesión nuevamente.');
        } else if (statusCode == 500) {
          throw NetPayException('Error en el servidor. Intenta más tarde.');
        } else {
          throw NetPayException(errorMessage);
        }
      } else {
        throw NetPayException(
            'Error de conexión. Revisa tu conexión a internet.');
      }
    } on SocketException {
      throw NetPayException('No hay conexión a internet. Revisa tu conexión.');
    } catch (e) {
      if (e is NetPayException) {
        rethrow;
      }
      throw NetPayException('Error inesperado: ${e.toString()}');
    }
  }
}

