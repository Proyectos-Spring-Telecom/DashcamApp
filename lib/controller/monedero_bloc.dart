import 'package:dashboardpro/services/monedero_service.dart';
import 'package:dashboardpro/model/monedero/monedero_model.dart';
import 'package:dashboardpro/model/monedero/pasajero_wallet_model.dart';
import 'package:dashboardpro/model/monedero/qr_wallet_model.dart';
import 'package:dashboardpro/model/monedero/cliente_model.dart';
import 'package:dashboardpro/model/monedero/pasajero_model.dart';
import 'package:dashboardpro/model/monedero/tipo_pasajero_model.dart';
import 'package:dashboardpro/model/monedero/monedero_request.dart';
import 'package:dashboardpro/model/monedero/monedero_response.dart';
import 'package:dashboardpro/model/transaccion/transaccion_request.dart';
import 'package:dashboardpro/model/transaccion/transaccion_response.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';
import 'package:dashboardpro/model/transaccion/paginacion_model.dart';
import 'package:dashboardpro/model/transaccion/recarga_request.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

enum MonederoStatus {
  initial,
  loading,
  loaded,
  error,
}

class MonederoBloc {
  final MonederoService _monederoService = MonederoService();
  final AuthBloc _authBloc = authBloc;

  final _monederosController =
      StreamController<List<MonederoModel>>.broadcast();
  final _statusController = StreamController<MonederoStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  final _transaccionesController =
      StreamController<List<TransaccionModel>>.broadcast();
  final _transaccionesStatusController =
      StreamController<MonederoStatus>.broadcast();
  final _transaccionesErrorController =
      StreamController<String?>.broadcast();

  final _walletController =
      StreamController<PasajeroWalletModel?>.broadcast();
  final _walletStatusController = StreamController<MonederoStatus>.broadcast();
  final _walletErrorController = StreamController<String?>.broadcast();

  final _qrController = StreamController<QrWalletModel?>.broadcast();
  final _qrStatusController = StreamController<MonederoStatus>.broadcast();
  final _qrErrorController = StreamController<String?>.broadcast();

  final _clientesController = StreamController<List<ClienteModel>>.broadcast();
  final _clientesStatusController = StreamController<MonederoStatus>.broadcast();
  final _clientesErrorController = StreamController<String?>.broadcast();

  final _pasajerosController = StreamController<List<PasajeroModel>>.broadcast();
  final _pasajerosStatusController = StreamController<MonederoStatus>.broadcast();
  final _pasajerosErrorController = StreamController<String?>.broadcast();

  final _tiposPasajeroController = StreamController<List<TipoPasajeroModel>>.broadcast();
  final _tiposPasajeroStatusController = StreamController<MonederoStatus>.broadcast();
  final _tiposPasajeroErrorController = StreamController<String?>.broadcast();

  final _crearMonederoStatusController = StreamController<MonederoStatus>.broadcast();
  final _crearMonederoErrorController = StreamController<String?>.broadcast();
  final _crearMonederoResponseController = StreamController<MonederoResponse?>.broadcast();

  Stream<List<MonederoModel>> get monederosStream =>
      _monederosController.stream;
  Stream<MonederoStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  Stream<List<TransaccionModel>> get transaccionesStream =>
      _transaccionesController.stream;
  Stream<MonederoStatus> get transaccionesStatusStream =>
      _transaccionesStatusController.stream;
  Stream<String?> get transaccionesErrorStream =>
      _transaccionesErrorController.stream;

  Stream<PasajeroWalletModel?> get walletStream =>
      _walletController.stream;
  Stream<MonederoStatus> get walletStatusStream =>
      _walletStatusController.stream;
  Stream<String?> get walletErrorStream =>
      _walletErrorController.stream;

  Stream<QrWalletModel?> get qrStream => _qrController.stream;
  Stream<MonederoStatus> get qrStatusStream => _qrStatusController.stream;
  Stream<String?> get qrErrorStream => _qrErrorController.stream;

  Stream<List<ClienteModel>> get clientesStream => _clientesController.stream;
  Stream<MonederoStatus> get clientesStatusStream => _clientesStatusController.stream;
  Stream<String?> get clientesErrorStream => _clientesErrorController.stream;

  Stream<List<PasajeroModel>> get pasajerosStream => _pasajerosController.stream;
  Stream<MonederoStatus> get pasajerosStatusStream => _pasajerosStatusController.stream;
  Stream<String?> get pasajerosErrorStream => _pasajerosErrorController.stream;

  Stream<List<TipoPasajeroModel>> get tiposPasajeroStream => _tiposPasajeroController.stream;
  Stream<MonederoStatus> get tiposPasajeroStatusStream => _tiposPasajeroStatusController.stream;
  Stream<String?> get tiposPasajeroErrorStream => _tiposPasajeroErrorController.stream;

  Stream<MonederoStatus> get crearMonederoStatusStream => _crearMonederoStatusController.stream;
  Stream<String?> get crearMonederoErrorStream => _crearMonederoErrorController.stream;
  Stream<MonederoResponse?> get crearMonederoResponseStream => _crearMonederoResponseController.stream;

  MonederoStatus _status = MonederoStatus.initial;
  List<MonederoModel> _monederos = [];
  String? _errorMessage;
  PaginacionModel? _paginacionMonederos;
  bool _isLoadingMoreMonederos = false;
  static const int _limitMonederos = 10;

  MonederoStatus _transaccionesStatus = MonederoStatus.initial;
  List<TransaccionModel> _transacciones = [];
  String? _transaccionesErrorMessage;
  PaginacionModel? _paginacion;
  bool _isLoadingMore = false;
  String? _fechaInicio;
  String? _fechaFin;
  static const int _limit = 20;

  MonederoStatus _walletStatus = MonederoStatus.initial;
  PasajeroWalletModel? _wallet;
  String? _walletErrorMessage;

  MonederoStatus _qrStatus = MonederoStatus.initial;
  QrWalletModel? _qr;
  String? _qrErrorMessage;
  bool _qrUsado = false; // Flag para saber si el QR ya fue usado

  MonederoStatus _clientesStatus = MonederoStatus.initial;
  List<ClienteModel> _clientes = [];
  String? _clientesErrorMessage;

  MonederoStatus _pasajerosStatus = MonederoStatus.initial;
  List<PasajeroModel> _pasajeros = [];
  String? _pasajerosErrorMessage;

  MonederoStatus _tiposPasajeroStatus = MonederoStatus.initial;
  List<TipoPasajeroModel> _tiposPasajero = [];
  String? _tiposPasajeroErrorMessage;

  MonederoStatus _crearMonederoStatus = MonederoStatus.initial;
  String? _crearMonederoErrorMessage;
  MonederoResponse? _crearMonederoResponse;

  MonederoStatus get status => _status;
  List<MonederoModel> get monederos => List.unmodifiable(_monederos);
  String? get errorMessage => _errorMessage;
  PaginacionModel? get paginacionMonederos => _paginacionMonederos;
  bool get isLoadingMoreMonederos => _isLoadingMoreMonederos;
  bool get hasMorePagesMonederos => _paginacionMonederos != null && _paginacionMonederos!.page < _paginacionMonederos!.lastPage;

  MonederoStatus get transaccionesStatus => _transaccionesStatus;
  List<TransaccionModel> get transacciones => List.unmodifiable(_transacciones);
  String? get transaccionesErrorMessage => _transaccionesErrorMessage;
  PaginacionModel? get paginacion => _paginacion;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePages => _paginacion != null && _paginacion!.page < _paginacion!.lastPage;
  String? get fechaInicioFiltro => _fechaInicio;
  String? get fechaFinFiltro => _fechaFin;

  MonederoStatus get walletStatus => _walletStatus;
  PasajeroWalletModel? get wallet => _wallet;
  String? get walletErrorMessage => _walletErrorMessage;

  MonederoStatus get qrStatus => _qrStatus;
  QrWalletModel? get qr => _qr;
  String? get qrErrorMessage => _qrErrorMessage;
  bool get qrUsado => _qrUsado;

  MonederoStatus get clientesStatus => _clientesStatus;
  List<ClienteModel> get clientes => List.unmodifiable(_clientes);
  String? get clientesErrorMessage => _clientesErrorMessage;

  MonederoStatus get pasajerosStatus => _pasajerosStatus;
  List<PasajeroModel> get pasajeros => List.unmodifiable(_pasajeros);
  String? get pasajerosErrorMessage => _pasajerosErrorMessage;

  MonederoStatus get tiposPasajeroStatus => _tiposPasajeroStatus;
  List<TipoPasajeroModel> get tiposPasajero => List.unmodifiable(_tiposPasajero);
  String? get tiposPasajeroErrorMessage => _tiposPasajeroErrorMessage;

  MonederoStatus get crearMonederoStatus => _crearMonederoStatus;
  String? get crearMonederoErrorMessage => _crearMonederoErrorMessage;
  MonederoResponse? get crearMonederoResponse => _crearMonederoResponse;

  MonederoBloc();

  /// Obtiene la lista de monederos activos desde el API (primera página)
  Future<void> obtenerMonederos() async {
    try {
      _status = MonederoStatus.loading;
      _statusController.add(_status);
      _errorController.add(null);
      _errorMessage = null;
      _isLoadingMoreMonederos = false;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Obteniendo monederos activos (página 1) con token: ${token.substring(0, 20)}...');

      final response = await _monederoService.obtenerListaMonederos(
        token,
        page: 1,
        limit: _limitMonederos,
      );

      _monederos = response.data;
      _paginacionMonederos = response.paginacion;
      _status = MonederoStatus.loaded;
      _statusController.add(_status);
      _monederosController.add(_monederos);
      _errorController.add(null);
      _errorMessage = null;

      debugPrint('✅ Monederos obtenidos exitosamente: ${response.data.length}');
      debugPrint('✅ Paginación: página ${response.paginacion.page}/${response.paginacion.lastPage} (total: ${response.paginacion.total})');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en obtenerMonederos: ${e.message}');
      _status = MonederoStatus.error;
      _errorMessage = e.message;
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _monederosController.add([]);
      _isLoadingMoreMonederos = false;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerMonederos: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _status = MonederoStatus.error;
      _errorMessage = 'No se pudo obtener la información. Intenta más tarde.';
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _monederosController.add([]);
      _isLoadingMoreMonederos = false;
    }
  }

  /// Carga la siguiente página de monederos (scroll infinito)
  Future<void> cargarMasMonederos() async {
    // Evitar múltiples llamadas simultáneas
    if (_isLoadingMoreMonederos || !hasMorePagesMonederos) {
      return;
    }

    try {
      _isLoadingMoreMonederos = true;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      // Calcular la siguiente página basándose en la paginación actual
      final currentPage = _paginacionMonederos?.page ?? 0;
      final nextPage = currentPage + 1;
      
      debugPrint('📤 Cargando más monederos...');
      debugPrint('📤 Página actual: $currentPage');
      debugPrint('📤 Página siguiente: $nextPage');
      debugPrint('📤 Monederos actuales: ${_monederos.length}');
      debugPrint('📤 Última página: ${_paginacionMonederos?.lastPage}');

      final response = await _monederoService.obtenerListaMonederos(
        token,
        page: nextPage,
        limit: _limitMonederos,
      );

      // Agregar los nuevos monederos a la lista existente
      final monederosAnteriores = _monederos.length;
      _monederos = [..._monederos, ...response.data];
      _paginacionMonederos = response.paginacion;
      _monederosController.add(_monederos);
      _isLoadingMoreMonederos = false;

      debugPrint('✅ Más monederos cargados: ${response.data.length}');
      debugPrint('✅ Total de monederos ahora: ${_monederos.length} (antes: $monederosAnteriores)');
      debugPrint('✅ Paginación actualizada: página ${response.paginacion.page}/${response.paginacion.lastPage} (total: ${response.paginacion.total})');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en cargarMasMonederos: ${e.message}');
      _isLoadingMoreMonederos = false;
      // No actualizar el estado de error para no interrumpir la lista actual
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en cargarMasMonederos: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _isLoadingMoreMonederos = false;
      // No actualizar el estado de error para no interrumpir la lista actual
    }
  }

  /// Refresca la lista de monederos
  Future<void> refreshMonederos() async {
    await obtenerMonederos();
  }

  /// Realiza una recarga a un monedero (método reutilizable)
  /// Este método puede ser usado tanto desde POS como desde Resumen
  /// [numeroSerieMonedero]: Número de serie del monedero a recargar
  /// [monto]: Monto a recargar
  /// [idMetodoPago]: ID del método de pago (1 = Efectivo, 3 o 4 = Tarjeta)
  /// [tokenCardNetPay]: Token de la tarjeta NetPay (requerido si idMetodoPago es 3 o 4)
  /// [deviceFingerPrint]: Device fingerprint de la tarjeta (requerido si idMetodoPago es 3 o 4)
  /// [latitudInicial]: Latitud opcional de la ubicación inicial
  /// [longitudInicial]: Longitud opcional de la ubicación inicial
  /// [numeroSerieValidador]: Número de serie del validador opcional
  /// [idDireccion]: ID de dirección obtenido de la tarjeta seleccionada (opcional)
  /// [deviceInformation]: Información del dispositivo (opcional)
  Future<TransaccionResponse?> realizarRecarga({
    required String numeroSerieMonedero,
    required double monto,
    required int idMetodoPago,
    String? tokenCardNetPay,
    String? deviceFingerPrint,
    double? latitudInicial,
    double? longitudInicial,
    String? numeroSerieValidador,
    int? idDireccion,
    Map<String, dynamic>? deviceInformation,
  }) async {
    try {
      // Validaciones previas
      if (numeroSerieMonedero.isEmpty) {
        throw MonederoException('El número de serie del monedero no es válido.');
      }

      if (monto <= 0) {
        throw MonederoException('El monto debe ser mayor a 0.');
      }

      // Validar que si es tarjeta, se proporcionen los datos necesarios
      if (idMetodoPago == 3 || idMetodoPago == 4) {
        if (tokenCardNetPay == null || tokenCardNetPay.isEmpty) {
          throw MonederoException('El token de la tarjeta es requerido para pagos con tarjeta.');
        }
        if (deviceFingerPrint == null || deviceFingerPrint.isEmpty) {
          throw MonederoException('El device fingerprint es requerido para pagos con tarjeta.');
        }
        if (idDireccion == null) {
          throw MonederoException('El idDireccion es obligatorio cuando el método de pago es Tarjeta.');
        }
      }
      
      // Para tarjeta, transactionTokenIdNetPay es obligatorio y debe ser el deviceFingerPrint
      String? transactionTokenIdNetPay;
      if (idMetodoPago == 3 || idMetodoPago == 4) {
        transactionTokenIdNetPay = deviceFingerPrint; // Usar deviceFingerPrint como transactionTokenIdNetPay
      }

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Realizando recarga: numeroSerieMonedero=$numeroSerieMonedero, monto=$monto, idMetodoPago=$idMetodoPago');

      // Crear el request de recarga
      final request = RecargaRequest(
        idTipoTransaccion: 1, // ID para tipo de transacción RECARGA
        monto: monto,
        latitudInicial: latitudInicial,
        longitudInicial: longitudInicial,
        numeroSerieMonedero: numeroSerieMonedero,
        numeroSerieValidador: numeroSerieValidador,
        idMetodoPago: idMetodoPago,
        tokenCardNetPay: tokenCardNetPay,
        transactionTokenIdNetPay: transactionTokenIdNetPay, // Obligatorio para tarjeta, usa deviceFingerPrint
        referenceIdNetPay: deviceFingerPrint, // referenceIdNetPay usa deviceFingerPrint
        sessionId: deviceFingerPrint, // sessionId usa deviceFingerPrint
        deviceFingerPrint: deviceFingerPrint,
        idDireccion: idDireccion, // Obtenido de la tarjeta seleccionada del servicio /netpay/customers
        deviceInformation: deviceInformation,
      );

      final response = await _monederoService.realizarRecarga(request, token);

      debugPrint('✅ Recarga realizada exitosamente: ${response.message}');

      // Refrescar la lista de monederos para actualizar saldos
      await refreshMonederos();
      
      // Refrescar el wallet para actualizar el saldo total y última recarga
      await refreshWallet();

      return response;
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en realizarRecarga: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en realizarRecarga: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      throw MonederoException('No se pudo realizar la recarga, intenta más tarde.');
    }
  }

  /// Realiza una recarga a un monedero (método legacy para POS - solo efectivo)
  /// [numeroSerieMonedero]: Número de serie del monedero a recargar
  /// [monto]: Monto a recargar (debe ser >= 10)
  /// [latitudInicial]: Latitud opcional de la ubicación inicial
  /// [longitudInicial]: Longitud opcional de la ubicación inicial
  /// [numeroSerieValidador]: Número de serie del validador opcional
  Future<TransaccionResponse?> realizarCargo({
    required String numeroSerieMonedero,
    required double monto,
    double? latitudInicial,
    double? longitudInicial,
    String? numeroSerieValidador,
  }) async {
    try {
      // Validaciones previas
      if (monto < 10) {
        throw MonederoException('El monto debe ser mayor o igual a 10.');
      }

      // Usar el método reutilizable con idMetodoPago = 1 (Efectivo)
      return await realizarRecarga(
        numeroSerieMonedero: numeroSerieMonedero,
        monto: monto,
        idMetodoPago: 1, // Efectivo
        latitudInicial: latitudInicial,
        longitudInicial: longitudInicial,
        numeroSerieValidador: numeroSerieValidador,
      );
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en realizarCargo: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en realizarCargo: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      throw MonederoException('No se pudo realizar el cargo, intenta más tarde.');
    }
  }

  /// Obtiene la lista de transacciones desde el API (primera página)
  /// Opcionalmente puede recibir filtros de fecha
  /// [fechaInicio]: Fecha de inicio en formato "YYYY-MM-DD" (opcional)
  /// [fechaFin]: Fecha de fin en formato "YYYY-MM-DD" (opcional)
  /// [resetFilters]: Si es true, resetea los filtros de fecha guardados
  Future<void> obtenerTransacciones({
    String? fechaInicio,
    String? fechaFin,
    bool resetFilters = false,
  }) async {
    try {
      // Actualizar filtros si se proporcionan
      if (resetFilters) {
        _fechaInicio = null;
        _fechaFin = null;
      } else {
        if (fechaInicio != null) _fechaInicio = fechaInicio;
        if (fechaFin != null) _fechaFin = fechaFin;
      }

      _transaccionesStatus = MonederoStatus.loading;
      _transaccionesStatusController.add(_transaccionesStatus);
      _transaccionesErrorController.add(null);
      _transaccionesErrorMessage = null;
      _isLoadingMore = false;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Obteniendo transacciones (página 1) con filtros: fechaInicio=$_fechaInicio, fechaFin=$_fechaFin');

      final response = await _monederoService.obtenerListaTransacciones(
        token: token,
        page: 1,
        limit: _limit,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );

      _transacciones = response.data;
      _paginacion = response.paginacion;
      _transaccionesStatus = MonederoStatus.loaded;
      _transaccionesStatusController.add(_transaccionesStatus);
      _transaccionesController.add(_transacciones);
      _transaccionesErrorController.add(null);
      _transaccionesErrorMessage = null;

      debugPrint('✅ Transacciones obtenidas exitosamente: ${response.data.length}');
      debugPrint('✅ Paginación: página ${response.paginacion.page}/${response.paginacion.lastPage} (total: ${response.paginacion.total})');
      if (response.paginacion.total > 0 && response.data.isEmpty) {
        debugPrint('⚠️ ADVERTENCIA: El servidor reporta ${response.paginacion.total} transacciones pero la lista está vacía');
      }
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en obtenerTransacciones: ${e.message}');
      _transaccionesStatus = MonederoStatus.error;
      _transaccionesErrorMessage = e.message;
      _transaccionesStatusController.add(_transaccionesStatus);
      _transaccionesErrorController.add(_transaccionesErrorMessage);
      _transaccionesController.add([]);
      _isLoadingMore = false;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerTransacciones: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _transaccionesStatus = MonederoStatus.error;
      _transaccionesErrorMessage = 'No se pudo obtener la información. Intenta más tarde.';
      _transaccionesStatusController.add(_transaccionesStatus);
      _transaccionesErrorController.add(_transaccionesErrorMessage);
      _transaccionesController.add([]);
      _isLoadingMore = false;
    }
  }

  /// Carga la siguiente página de transacciones (scroll infinito)
  Future<void> cargarMasTransacciones() async {
    // Evitar múltiples llamadas simultáneas
    if (_isLoadingMore || !hasMorePages) {
      return;
    }

    try {
      _isLoadingMore = true;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      // Calcular la siguiente página basándose en la paginación actual
      final currentPage = _paginacion?.page ?? 0;
      final nextPage = currentPage + 1;
      
      debugPrint('📤 Cargando más transacciones...');
      debugPrint('📤 Página actual: $currentPage');
      debugPrint('📤 Página siguiente: $nextPage');
      debugPrint('📤 Transacciones actuales: ${_transacciones.length}');
      debugPrint('📤 Última página: ${_paginacion?.lastPage}');

      final response = await _monederoService.obtenerListaTransacciones(
        token: token,
        page: nextPage,
        limit: _limit,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );

      // Agregar las nuevas transacciones a la lista existente
      final transaccionesAnteriores = _transacciones.length;
      _transacciones = [..._transacciones, ...response.data];
      _paginacion = response.paginacion;
      _transaccionesController.add(_transacciones);
      _isLoadingMore = false;

      debugPrint('✅ Más transacciones cargadas: ${response.data.length}');
      debugPrint('✅ Total de transacciones ahora: ${_transacciones.length} (antes: $transaccionesAnteriores)');
      debugPrint('✅ Paginación actualizada: página ${response.paginacion.page}/${response.paginacion.lastPage} (total: ${response.paginacion.total})');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en cargarMasTransacciones: ${e.message}');
      _isLoadingMore = false;
      // No actualizar el estado de error para no interrumpir la lista actual
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en cargarMasTransacciones: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _isLoadingMore = false;
      // No actualizar el estado de error para no interrumpir la lista actual
    }
  }

  /// Refresca la lista de transacciones (reinicia a página 1)
  Future<void> refreshTransacciones() async {
    await obtenerTransacciones();
  }

  /// Obtiene la información del wallet del pasajero logueado
  /// [anio] es opcional, si no se proporciona se usa el año actual
  Future<void> obtenerWallet({int? anio}) async {
    try {
      _walletStatus = MonederoStatus.loading;
      _walletStatusController.add(_walletStatus);
      _walletErrorController.add(null);
      _walletErrorMessage = null;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Obteniendo wallet con token: ${token.substring(0, 20)}...');

      final wallet = await _monederoService.obtenerWallet(token, anio: anio);

      _wallet = wallet;
      _walletStatus = MonederoStatus.loaded;
      _walletStatusController.add(_walletStatus);
      _walletController.add(_wallet);
      _walletErrorController.add(null);
      _walletErrorMessage = null;

      debugPrint('✅ Wallet obtenido exitosamente');
      debugPrint('✅ Saldo Total: ${wallet.saldoTotal}');
      debugPrint('✅ Monederos: ${wallet.monederos}');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en obtenerWallet: ${e.message}');
      _walletStatus = MonederoStatus.error;
      _walletErrorMessage = e.message;
      _walletStatusController.add(_walletStatus);
      _walletErrorController.add(_walletErrorMessage);
      _walletController.add(null);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerWallet: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _walletStatus = MonederoStatus.error;
      _walletErrorMessage = 'No se pudo obtener la información. Intenta más tarde.';
      _walletStatusController.add(_walletStatus);
      _walletErrorController.add(_walletErrorMessage);
      _walletController.add(null);
    }
  }

  /// Refresca la información del wallet
  Future<void> refreshWallet() async {
    await obtenerWallet();
  }

  /// Obtiene el código QR para saldo
  /// Si hay un QR en caché y no ha sido usado, lo retorna sin hacer nueva petición
  /// Si el QR fue usado, genera uno nuevo
  /// * UPDATE: Genera el código QR para saldo con número de pasajes
  /// [numeroPasajes] es requerido y debe ser mayor a 0
  /// [forzarNuevo] fuerza la generación de un nuevo QR incluso si hay uno en caché
  Future<void> obtenerQrSaldo({required int numeroPasajes, bool forzarNuevo = false}) async {
    try {
      // * IMPORTANT: Validar numeroPasajes antes de continuar
      if (numeroPasajes <= 0) {
        throw MonederoException('El número de pasajes debe ser mayor a 0.');
      }

      // * UPDATE: Si hay un QR en caché pero el numeroPasajes es diferente, forzar nuevo
      // Si hay un QR en caché, no fue usado y no se fuerza nuevo, retornar el caché
      if (!forzarNuevo && _qr != null && !_qrUsado && _qrStatus == MonederoStatus.loaded) {
        // * Verificar si el numeroPasajes coincide con el QR en caché
        if (_qr!.numeroPasajes == numeroPasajes) {
          debugPrint('✅ Retornando QR desde caché (ID: ${_qr!.idQR}, Pasajes: ${_qr!.numeroPasajes})');
          // Asegurar que el estado esté en loaded y emitir el QR
          _qrStatusController.add(_qrStatus);
          _qrController.add(_qr);
          return;
        } else {
          debugPrint('🔄 NumeroPasajes diferente (caché: ${_qr!.numeroPasajes}, nuevo: $numeroPasajes), generando nuevo QR...');
          forzarNuevo = true;
        }
      }

      // Si el QR fue usado o se fuerza nuevo, limpiar caché antes de generar uno nuevo
      if (_qrUsado || forzarNuevo) {
        debugPrint('🔄 ${_qrUsado ? "QR anterior fue usado" : "Forzando nuevo QR"}, limpiando caché...');
        _qr = null;
        _qrUsado = false;
      }

      _qrStatus = MonederoStatus.loading;
      _qrStatusController.add(_qrStatus);
      _qrErrorController.add(null);
      _qrErrorMessage = null;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Generando código QR para saldo con $numeroPasajes pasaje(s)...');

      // * UPDATE: Pasar numeroPasajes al servicio
      final response = await _monederoService.obtenerQrSaldo(token, numeroPasajes);

      _qr = response.data;
      _qrUsado = false; // El nuevo QR aún no ha sido usado
      _qrStatus = MonederoStatus.loaded;
      _qrStatusController.add(_qrStatus);
      _qrController.add(_qr);
      _qrErrorController.add(null);
      _qrErrorMessage = null;

      debugPrint('✅ QR generado exitosamente (ID: ${_qr!.idQR}, Pasajes: ${_qr!.numeroPasajes ?? 'N/A'})');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en obtenerQrSaldo: ${e.message}');
      _qrStatus = MonederoStatus.error;
      _qrErrorMessage = e.message;
      _qrStatusController.add(_qrStatus);
      _qrErrorController.add(_qrErrorMessage);
      _qrController.add(null);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerQrSaldo: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _qrStatus = MonederoStatus.error;
      _qrErrorMessage = 'No se pudo generar el código QR. Intenta más tarde.';
      _qrStatusController.add(_qrStatus);
      _qrErrorController.add(_qrErrorMessage);
      _qrController.add(null);
    }
  }

  /// Marca el QR como usado y lo elimina de caché
  /// Debe llamarse cuando el QR se utiliza para realizar un débito
  void marcarQrComoUsado() {
    if (_qr != null) {
      debugPrint('🗑️ Marcando QR como usado y limpiando caché (ID: ${_qr!.idQR})');
      _qrUsado = true;
      _limpiarQrCache();
    }
  }

  /// Limpia el caché del QR
  void _limpiarQrCache() {
    _qr = null;
    _qrUsado = false;
    _qrController.add(null);
  }

  /// Limpia el caché del QR (método público)
  void limpiarQrCache() {
    _limpiarQrCache();
  }

  /// Obtiene la lista de clientes desde el API
  Future<void> obtenerClientes() async {
    try {
      _clientesStatus = MonederoStatus.loading;
      _clientesStatusController.add(_clientesStatus);
      _clientesErrorController.add(null);
      _clientesErrorMessage = null;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Obteniendo clientes con token: ${token.substring(0, 20)}...');

      final clientes = await _monederoService.obtenerListaClientes(token);

      _clientes = clientes;
      _clientesStatus = MonederoStatus.loaded;
      _clientesStatusController.add(_clientesStatus);
      _clientesController.add(_clientes);
      _clientesErrorController.add(null);
      _clientesErrorMessage = null;

      debugPrint('✅ Clientes obtenidos exitosamente: ${clientes.length}');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en obtenerClientes: ${e.message}');
      _clientesStatus = MonederoStatus.error;
      _clientesErrorMessage = e.message;
      _clientesStatusController.add(_clientesStatus);
      _clientesErrorController.add(_clientesErrorMessage);
      _clientesController.add([]);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerClientes: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _clientesStatus = MonederoStatus.error;
      _clientesErrorMessage = 'No se pudo obtener la información. Intenta más tarde.';
      _clientesStatusController.add(_clientesStatus);
      _clientesErrorController.add(_clientesErrorMessage);
      _clientesController.add([]);
    }
  }

  /// Obtiene la lista de pasajeros desde el API
  Future<void> obtenerPasajeros() async {
    try {
      _pasajerosStatus = MonederoStatus.loading;
      _pasajerosStatusController.add(_pasajerosStatus);
      _pasajerosErrorController.add(null);
      _pasajerosErrorMessage = null;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Obteniendo pasajeros con token: ${token.substring(0, 20)}...');

      final pasajeros = await _monederoService.obtenerListaPasajeros(token);

      _pasajeros = pasajeros;
      _pasajerosStatus = MonederoStatus.loaded;
      _pasajerosStatusController.add(_pasajerosStatus);
      _pasajerosController.add(_pasajeros);
      _pasajerosErrorController.add(null);
      _pasajerosErrorMessage = null;

      debugPrint('✅ Pasajeros obtenidos exitosamente: ${pasajeros.length}');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en obtenerPasajeros: ${e.message}');
      _pasajerosStatus = MonederoStatus.error;
      _pasajerosErrorMessage = e.message;
      _pasajerosStatusController.add(_pasajerosStatus);
      _pasajerosErrorController.add(_pasajerosErrorMessage);
      _pasajerosController.add([]);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerPasajeros: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _pasajerosStatus = MonederoStatus.error;
      _pasajerosErrorMessage = 'No se pudo obtener la información. Intenta más tarde.';
      _pasajerosStatusController.add(_pasajerosStatus);
      _pasajerosErrorController.add(_pasajerosErrorMessage);
      _pasajerosController.add([]);
    }
  }

  /// Obtiene la lista de tipos de pasajero desde el API
  /// La respuesta ya viene filtrada por el idCliente del usuario logueado
  Future<void> obtenerTiposPasajero() async {
    try {
      _tiposPasajeroStatus = MonederoStatus.loading;
      _tiposPasajeroStatusController.add(_tiposPasajeroStatus);
      _tiposPasajeroErrorController.add(null);
      _tiposPasajeroErrorMessage = null;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Obteniendo tipos de pasajero con token: ${token.substring(0, 20)}...');

      final tiposPasajero = await _monederoService.obtenerListaTiposPasajero(token);

      _tiposPasajero = tiposPasajero;
      _tiposPasajeroStatus = MonederoStatus.loaded;
      _tiposPasajeroStatusController.add(_tiposPasajeroStatus);
      _tiposPasajeroController.add(_tiposPasajero);
      _tiposPasajeroErrorController.add(null);
      _tiposPasajeroErrorMessage = null;

      debugPrint('✅ Tipos de pasajero obtenidos exitosamente: ${tiposPasajero.length}');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en obtenerTiposPasajero: ${e.message}');
      _tiposPasajeroStatus = MonederoStatus.error;
      _tiposPasajeroErrorMessage = e.message;
      _tiposPasajeroStatusController.add(_tiposPasajeroStatus);
      _tiposPasajeroErrorController.add(_tiposPasajeroErrorMessage);
      _tiposPasajeroController.add([]);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en obtenerTiposPasajero: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _tiposPasajeroStatus = MonederoStatus.error;
      _tiposPasajeroErrorMessage = 'No se pudo obtener la información. Intenta más tarde.';
      _tiposPasajeroStatusController.add(_tiposPasajeroStatus);
      _tiposPasajeroErrorController.add(_tiposPasajeroErrorMessage);
      _tiposPasajeroController.add([]);
    }
  }

  /// Crea un nuevo monedero
  Future<void> crearMonedero(MonederoRequest request) async {
    try {
      _crearMonederoStatus = MonederoStatus.loading;
      _crearMonederoStatusController.add(_crearMonederoStatus);
      _crearMonederoErrorController.add(null);
      _crearMonederoErrorMessage = null;
      _crearMonederoResponse = null;

      // Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonederoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Creando monedero con token: ${token.substring(0, 20)}...');

      final response = await _monederoService.crearMonedero(request, token);

      _crearMonederoResponse = response;
      _crearMonederoStatus = MonederoStatus.loaded;
      _crearMonederoStatusController.add(_crearMonederoStatus);
      _crearMonederoResponseController.add(_crearMonederoResponse);
      _crearMonederoErrorController.add(null);
      _crearMonederoErrorMessage = null;

      debugPrint('✅ Monedero creado exitosamente: ID ${response.data.id}');
    } on MonederoException catch (e) {
      debugPrint('❌ MonederoException en crearMonedero: ${e.message}');
      _crearMonederoStatus = MonederoStatus.error;
      _crearMonederoErrorMessage = e.message;
      _crearMonederoStatusController.add(_crearMonederoStatus);
      _crearMonederoErrorController.add(_crearMonederoErrorMessage);
      _crearMonederoResponseController.add(null);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en crearMonedero: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _crearMonederoStatus = MonederoStatus.error;
      _crearMonederoErrorMessage = 'No se pudo crear el monedero. Intenta más tarde.';
      _crearMonederoStatusController.add(_crearMonederoStatus);
      _crearMonederoErrorController.add(_crearMonederoErrorMessage);
      _crearMonederoResponseController.add(null);
    }
  }

  void dispose() {
    _monederosController.close();
    _statusController.close();
    _errorController.close();
    _transaccionesController.close();
    _transaccionesStatusController.close();
    _transaccionesErrorController.close();
    _walletController.close();
    _walletStatusController.close();
    _walletErrorController.close();
    _qrController.close();
    _qrStatusController.close();
    _qrErrorController.close();
    _clientesController.close();
    _clientesStatusController.close();
    _clientesErrorController.close();
    _pasajerosController.close();
    _pasajerosStatusController.close();
    _pasajerosErrorController.close();
    _tiposPasajeroController.close();
    _tiposPasajeroStatusController.close();
    _tiposPasajeroErrorController.close();
    _crearMonederoStatusController.close();
    _crearMonederoErrorController.close();
    _crearMonederoResponseController.close();
  }
}

// Instancia global del MonederoBloc
final monederoBloc = MonederoBloc();

