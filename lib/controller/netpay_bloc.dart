import 'package:dashboardpro/services/netpay_service.dart';
import 'package:dashboardpro/model/netpay/netpay_customer_model.dart';
import 'package:dashboardpro/model/netpay/assign_card_token_request.dart';
import 'package:dashboardpro/model/netpay/create_customer_request.dart';
import 'package:dashboardpro/model/netpay/create_customer_response.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

enum NetPayStatus {
  idle,
  loading,
  tokenizing, // Estado para cuando se está tokenizando la tarjeta
  creating,   // Estado para cuando se está creando un cliente
  assigning,  // Estado para cuando se está asignando el token al cliente
  deleting,   // Estado para cuando se está eliminando una tarjeta
  success,
  empty,
  error,
}

class NetPayBloc {
  final NetPayService _netPayService = NetPayService();
  final AuthBloc _authBloc = authBloc;

  final _customerController = StreamController<NetPayCustomerModel?>.broadcast();
  final _statusController = StreamController<NetPayStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  Stream<NetPayCustomerModel?> get customerStream => _customerController.stream;
  Stream<NetPayStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  NetPayStatus _currentStatus = NetPayStatus.idle;
  NetPayCustomerModel? _currentCustomer;
  bool _isDeleting = false; // Flag para indicar que se está eliminando una tarjeta
  
  // Sistema de caché para optimizar la carga
  String? _cachedCustomerId; // ID del cliente que está en caché
  DateTime? _cacheTimestamp; // Timestamp de la última carga exitosa
  static const Duration _cacheValidityDuration = Duration(minutes: 5); // Caché válido por 5 minutos

  NetPayStatus get currentStatus => _currentStatus;
  NetPayCustomerModel? get currentCustomer => _currentCustomer;
  
  /// Verifica si los datos en caché son válidos para el customerId dado
  bool _isCacheValid(String customerId) {
    // Si no hay datos en caché, no es válido
    if (_currentCustomer == null || _cachedCustomerId != customerId) {
      return false;
    }
    
    // Si no hay timestamp, no es válido
    if (_cacheTimestamp == null) {
      return false;
    }
    
    // Si el caché expiró, no es válido
    final now = DateTime.now();
    final cacheAge = now.difference(_cacheTimestamp!);
    if (cacheAge > _cacheValidityDuration) {
      return false;
    }
    
    // Si el estado no es success, no es válido
    if (_currentStatus != NetPayStatus.success && _currentStatus != NetPayStatus.empty) {
      return false;
    }
    
    return true;
  }
  
  /// Invalida el caché (útil cuando se agrega o elimina una tarjeta)
  void _invalidateCache() {
    _cachedCustomerId = null;
    _cacheTimestamp = null;
  }

  /// Consulta la información del cliente NetPay y sus tarjetas registradas
  /// [customerId] es el ID del cliente en NetPay (customerIdNetPay del wallet)
  /// [silent] si es true, no establece el estado a loading (útil para recargas silenciosas después de operaciones)
  /// [forceRefresh] si es true, fuerza la recarga incluso si hay datos en caché válidos
  Future<void> obtenerClienteNetPay(String customerId, {bool silent = false, bool forceRefresh = false}) async {
    try {
      // Validar que se proporcionó el customerId
      if (customerId.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El ID del cliente es requerido.');
        return;
      }

      // Verificar caché antes de hacer la llamada (solo si no se fuerza la recarga)
      if (!forceRefresh && _isCacheValid(customerId)) {
        debugPrint('✅ Usando datos en caché para cliente $customerId');
        // Los datos ya están en _currentCustomer y el estado ya está configurado
        // Solo emitir los streams para actualizar la UI si no es silenciosa
        if (!silent) {
          _statusController.add(_currentStatus);
          _customerController.add(_currentCustomer);
          _errorController.add(null);
        }
        return;
      }

      // Evitar múltiples cargas simultáneas del mismo cliente (solo si no es silenciosa)
      if (!silent && _currentStatus == NetPayStatus.loading && _currentCustomer?.id == customerId) {
        debugPrint('⏳ Ya se está cargando el cliente $customerId, omitiendo carga duplicada');
        return;
      }

      // Obtener token de autenticación
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
        return;
      }

      // Validar que el customerId no esté vacío o mal formado
      if (customerId.trim().isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El ID del cliente NetPay no está disponible. Por favor, verifica tu información.');
        return;
      }

      debugPrint('🔍 NetPayBloc - Iniciando carga de métodos de pago');
      debugPrint('🔍 customerId recibido: $customerId');
      debugPrint('🔍 customerId length: ${customerId.length}');
      debugPrint('🔍 Token disponible: ${token.isNotEmpty}');
      debugPrint('🔍 Silent mode: $silent');

      // Actualizar estado a loading solo si no es silenciosa
      if (!silent) {
        _currentStatus = NetPayStatus.loading;
        _statusController.add(_currentStatus);
        _errorController.add(null);
      }

      // Consultar el servicio
      final customer = await _netPayService.obtenerClienteNetPay(
        customerId: customerId.trim(), // Asegurar que no haya espacios
        token: token,
      );

      // Verificar si hay tarjetas registradas
      if (customer.paymentSources.isEmpty) {
        _currentStatus = NetPayStatus.empty;
        _currentCustomer = null;
        _customerController.add(null);
      } else {
        _currentStatus = NetPayStatus.success;
        _currentCustomer = customer;
        _customerController.add(customer);
      }

      // Actualizar caché
      _cachedCustomerId = customerId;
      _cacheTimestamp = DateTime.now();

      _statusController.add(_currentStatus);
      _errorController.add(null);

      debugPrint('✅ Cliente NetPay obtenido exitosamente');
      debugPrint('✅ Estado: $_currentStatus');
      debugPrint('✅ Tarjetas encontradas: ${customer.paymentSources.length}');
      debugPrint('✅ Caché actualizado para cliente $customerId');
    } on NetPayException catch (e) {
      debugPrint('❌ NetPayException en obtenerClienteNetPay: ${e.message}');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      _errorController.add(e.message);
      _currentCustomer = null;
      _customerController.add(null);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerClienteNetPay: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      
      // Proporcionar mensajes de error más específicos y amigables
      String errorMessage = 'Error al cargar los métodos de pago.';
      if (e is NetPayException) {
        errorMessage = e.message;
      } else if (e.toString().contains('TimeoutException') || 
                 e.toString().contains('timeout')) {
        errorMessage = 'La solicitud está tardando demasiado. Por favor, verifica tu conexión e intenta nuevamente.';
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('connection')) {
        errorMessage = 'No hay conexión a internet. Por favor, verifica tu conexión.';
      } else if (e.toString().contains('FormatException') || 
                 e.toString().contains('parse')) {
        errorMessage = 'Error al procesar la respuesta del servidor. Por favor, intenta nuevamente.';
      }
      
      _errorController.add(errorMessage);
      _currentCustomer = null;
      _customerController.add(null);
    }
  }

  /// Crea un nuevo cliente en NetPay
  /// Este método se ejecuta cuando customerIdNetPay es null
  /// [firstName] nombre del cliente
  /// [lastName] apellido del cliente
  /// [email] correo electrónico del cliente
  /// [phone] teléfono del cliente
  /// [token] token de la tarjeta tokenizada
  /// [idPasajero] ID del pasajero
  /// Retorna el customerId del cliente creado
  Future<String> crearClienteNetPay({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String token,
    required int idPasajero,
  }) async {
    try {
      // Validaciones previas
      if (firstName.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El nombre es requerido.');
        throw NetPayException('El nombre es requerido.');
      }

      if (lastName.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El apellido es requerido.');
        throw NetPayException('El apellido es requerido.');
      }

      if (email.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El correo electrónico es requerido.');
        throw NetPayException('El correo electrónico es requerido.');
      }

      if (phone.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El teléfono es requerido.');
        throw NetPayException('El teléfono es requerido.');
      }

      if (token.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El token de la tarjeta es requerido.');
        throw NetPayException('El token de la tarjeta es requerido.');
      }

      // Obtener token de autenticación
      final authToken = _authBloc.currentToken;
      if (authToken == null || authToken.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
        throw NetPayException('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      // Actualizar estado a creating
      _currentStatus = NetPayStatus.creating;
      _statusController.add(_currentStatus);
      _errorController.add(null);

      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 NetPayBloc: Iniciando creación de cliente NetPay');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📝 Datos del cliente:');
      debugPrint('   - Nombre: $firstName');
      debugPrint('   - Apellido: $lastName');
      debugPrint('   - Email: $email');
      debugPrint('   - Teléfono: $phone');
      debugPrint('   - ID Pasajero: $idPasajero');
      debugPrint('───────────────────────────────────────────────────────────');

      // Crear el request
      final request = CreateCustomerRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        token: token,
        idPasajero: idPasajero,
      );

      // Ejecutar el servicio
      final response = await _netPayService.crearClienteNetPay(
        request: request,
        token: authToken,
      );

      // Validar que se obtuvo el customerId
      if (response.customerId.isEmpty) {
        throw NetPayException('No se recibió el ID del cliente del servidor.');
      }

      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('✅ NetPayBloc: Cliente creado exitosamente');
      debugPrint('✅ Customer ID recibido: ${response.customerId}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');

      // El estado se mantendrá en creating hasta que se complete la asignación
      // No cambiar a success aquí porque aún falta asignar la tarjeta

      return response.customerId;
    } on NetPayException catch (e) {
      debugPrint('❌ NetPayException en crearClienteNetPay: ${e.message}');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      _errorController.add(e.message);
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en crearClienteNetPay: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
      throw NetPayException('Error inesperado: ${e.toString()}');
    }
  }

  /// Asigna un token de tarjeta a un cliente NetPay
  /// Este método se ejecuta después de una tokenización exitosa
  /// [customerId] es el ID del cliente en NetPay (customerIdNetPay del wallet)
  /// [tokenCard] es el token de la tarjeta obtenido de la tokenización
  /// [cvv2] es el CVV de la tarjeta (se necesita para la asignación)
  /// [nombre] nombre del titular
  /// [apellidoPaterno] apellido paterno del titular
  /// [apellidoMaterno] apellido materno del titular
  /// [email] email del titular
  /// [telefono] teléfono del titular
  /// [direccion] datos de dirección opcionales
  /// [idDireccion] ID de dirección opcional
  Future<void> asignarTokenTarjeta({
    required String customerId,
    required String tokenCard,
    required String cvv2,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String email,
    required String telefono,
    DireccionData? direccion,
    int? idDireccion,
  }) async {
    try {
      // Validar que se proporcionó el customerId
      if (customerId.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El ID del cliente es requerido.');
        return;
      }

      if (tokenCard.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El token de la tarjeta es requerido.');
        return;
      }

      // Obtener token de autenticación
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
        return;
      }

      // Actualizar estado a assigning
      _currentStatus = NetPayStatus.assigning;
      _statusController.add(_currentStatus);
      _errorController.add(null);

      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 NetPayBloc: Iniciando asignación de tarjeta al cliente');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📝 Datos de asignación:');
      debugPrint('   - Customer ID: $customerId');
      debugPrint('   - Nombre: $nombre');
      debugPrint('   - Apellido Paterno: $apellidoPaterno');
      debugPrint('   - Apellido Materno: $apellidoMaterno');
      debugPrint('   - Email: $email');
      debugPrint('   - Teléfono: $telefono');
      debugPrint('   - ID Dirección: ${idDireccion ?? "null"}');
      debugPrint('───────────────────────────────────────────────────────────');

      // Generar referenceId único (usando timestamp + random para garantizar unicidad)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 1000000).toString().padLeft(6, '0');
      final referenceId = 'REF_${timestamp}_$random';

      // Crear el request
      final request = AssignCardTokenRequest(
        customerId: customerId,
        token: tokenCard,
        referenceId: referenceId,
        preAuth: false,
        cvv2: cvv2,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        email: email,
        telefono: telefono,
        idDireccion: idDireccion,
        direccion: direccion,
      );

      // Ejecutar el servicio
      await _netPayService.asignarTokenTarjeta(
        customerId: customerId,
        request: request,
        token: token,
      );

      // Actualizar estado a success
      _currentStatus = NetPayStatus.success;
      _statusController.add(_currentStatus);
      _errorController.add(null);
      
      // Invalidar caché para forzar recarga de tarjetas actualizadas
      _invalidateCache();
      
      // Recargar las tarjetas actualizadas de forma silenciosa
      await obtenerClienteNetPay(customerId, silent: true, forceRefresh: true);

      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('✅ NetPayBloc: Tarjeta asignada exitosamente al cliente');
      debugPrint('✅ Customer ID: $customerId');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
    } on NetPayException catch (e) {
      debugPrint('❌ NetPayException en asignarTokenTarjeta: ${e.message}');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      _errorController.add(e.message);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en asignarTokenTarjeta: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
    }
  }

  /// Elimina una tarjeta de un cliente NetPay
  /// [customerId] es el ID del cliente en NetPay (customerIdNetPay del wallet)
  /// [tokenCard] es el token de la tarjeta a eliminar
  Future<void> eliminarTarjeta({
    required String customerId,
    required String tokenCard,
  }) async {
    try {
      // Validar que se proporcionó el customerId
      if (customerId.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El ID del cliente es requerido.');
        return;
      }

      if (tokenCard.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('El token de la tarjeta es requerido.');
        return;
      }

      // Obtener token de autenticación
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        _currentStatus = NetPayStatus.error;
        _statusController.add(_currentStatus);
        _errorController.add('No hay token de autenticación. Por favor, inicia sesión nuevamente.');
        return;
      }

      // Marcar que se está eliminando
      _isDeleting = true;
      
      // Actualizar estado a deleting
      _currentStatus = NetPayStatus.deleting;
      _statusController.add(_currentStatus);
      _errorController.add(null);

      // Ejecutar el servicio
      await _netPayService.eliminarTarjeta(
        customerId: customerId,
        tokenCard: tokenCard,
        token: token,
      );

      // Invalidar caché para forzar recarga de tarjetas actualizadas
      _invalidateCache();
      
      // Recargar las tarjetas actualizadas de forma silenciosa (sin mostrar loading)
      await obtenerClienteNetPay(customerId, silent: true, forceRefresh: true);
      
      // Resetear el flag de eliminación
      _isDeleting = false;

      debugPrint('✅ Tarjeta eliminada exitosamente');
    } on NetPayException catch (e) {
      _isDeleting = false; // Resetear flag en caso de error
      debugPrint('❌ NetPayException en eliminarTarjeta: ${e.message}');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      _errorController.add(e.message);
    } catch (e, stackTrace) {
      _isDeleting = false; // Resetear flag en caso de error
      debugPrint('❌ Error inesperado en eliminarTarjeta: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _currentStatus = NetPayStatus.error;
      _statusController.add(_currentStatus);
      _errorController.add('Error inesperado: ${e.toString()}');
    }
  }
  
  /// Getter para verificar si se está eliminando una tarjeta
  bool get isDeleting => _isDeleting;

  /// Limpia el estado del BLoC
  /// Establece el estado a 'empty' para indicar que no hay tarjetas disponibles
  void limpiar() {
    _currentStatus = NetPayStatus.empty;
    _currentCustomer = null;
    _invalidateCache(); // Invalidar caché al limpiar
    _statusController.add(_currentStatus);
    _customerController.add(null);
    _errorController.add(null);
  }
  
  /// Fuerza una recarga de los métodos de pago (invalida caché y recarga)
  Future<void> refrescarMetodosPago(String customerId) async {
    _invalidateCache();
    await obtenerClienteNetPay(customerId, forceRefresh: true);
  }

  /// Libera los recursos del BLoC
  void dispose() {
    _customerController.close();
    _statusController.close();
    _errorController.close();
  }
}

// Instancia global del NetPayBloc
final netPayBloc = NetPayBloc();

