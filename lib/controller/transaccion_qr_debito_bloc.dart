import 'package:dashboardpro/services/transaccion_qr_debito_service.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';
import 'package:dashboardpro/model/transaccion/paginacion_model.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// ! BLOC: Transacciones Débito QR
// ? INFO: Gestiona listado paginado del día actual; filtrado por rol lo hace el backend.
// TODO: Permitir filtros por rango de fechas en el futuro.

/// * Estados del bloc de transacciones débito QR.
enum TransaccionQrDebitoStatus {
  initial,
  loading,
  loaded,
  error,
}

/// * Bloc para el listado paginado de transacciones débito QR (esQR = true).
/// Siempre usa fechaInicio/fechaFin del día actual en la primera carga.
class TransaccionQrDebitoBloc {
  final TransaccionQrDebitoService _service = TransaccionQrDebitoService();
  final AuthBloc _authBloc = authBloc;

  final _dataController = StreamController<List<TransaccionModel>>.broadcast();
  final _statusController = StreamController<TransaccionQrDebitoStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  List<TransaccionModel> _transacciones = [];
  TransaccionQrDebitoStatus _status = TransaccionQrDebitoStatus.initial;
  String? _errorMessage;
  PaginacionModel? _paginacion;
  bool _isLoadingMore = false;
  static const int _limit = 20;

  /// Fecha del día actual en formato YYYY-MM-DD (para solicitudes al API).
  static String get _fechaHoy {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<TransaccionModel> get transacciones => _transacciones;
  TransaccionQrDebitoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasMorePages =>
      _paginacion != null && _paginacion!.page < _paginacion!.lastPage;
  bool get isLoadingMore => _isLoadingMore;

  Stream<List<TransaccionModel>> get dataStream => _dataController.stream;
  Stream<TransaccionQrDebitoStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  /// * Carga la primera página (transacciones del día actual).
  Future<void> cargar() async {
    try {
      _status = TransaccionQrDebitoStatus.loading;
      _statusController.add(_status);
      _errorController.add(null);
      _errorMessage = null;
      _isLoadingMore = false;

      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw TransaccionQrDebitoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      final fechaHoy = _fechaHoy;
      debugPrint('📤 Cargando transacciones débito QR (día: $fechaHoy)');

      final response = await _service.obtenerTransaccionesDebitoQr(
        token,
        page: 1,
        limit: _limit,
        fechaInicio: fechaHoy,
        fechaFin: fechaHoy,
      );

      _transacciones = response.data;
      _paginacion = response.paginacion;
      _status = TransaccionQrDebitoStatus.loaded;
      _statusController.add(_status);
      _dataController.add(_transacciones);
      _errorController.add(null);
      _errorMessage = null;

      debugPrint('✅ Transacciones débito QR cargadas: ${_transacciones.length}');
    } on TransaccionQrDebitoException catch (e) {
      debugPrint('❌ TransaccionQrDebitoException: ${e.message}');
      _status = TransaccionQrDebitoStatus.error;
      _errorMessage = e.message;
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _dataController.add([]);
      _isLoadingMore = false;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en cargar: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _status = TransaccionQrDebitoStatus.error;
      _errorMessage = 'No fue posible cargar la información. Intenta más tarde.';
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _dataController.add([]);
      _isLoadingMore = false;
    }
  }

  /// * Carga la siguiente página (scroll infinito).
  Future<void> cargarMas() async {
    if (_isLoadingMore || !hasMorePages) return;

    try {
      _isLoadingMore = true;
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) return;

      final nextPage = (_paginacion?.page ?? 0) + 1;
      final fechaHoy = _fechaHoy;

      final response = await _service.obtenerTransaccionesDebitoQr(
        token,
        page: nextPage,
        limit: _limit,
        fechaInicio: fechaHoy,
        fechaFin: fechaHoy,
      );

      _transacciones = [..._transacciones, ...response.data];
      _paginacion = response.paginacion;
      _dataController.add(_transacciones);
      _isLoadingMore = false;

      debugPrint('✅ Más transacciones débito QR: +${response.data.length}');
    } on TransaccionQrDebitoException catch (e) {
      debugPrint('❌ TransaccionQrDebitoException en cargarMas: ${e.message}');
      _isLoadingMore = false;
    } catch (e) {
      debugPrint('❌ Error en cargarMas: $e');
      _isLoadingMore = false;
    }
  }

  void limpiarError() {
    _errorMessage = null;
    _errorController.add(null);
  }

  void dispose() {
    _dataController.close();
    _statusController.close();
    _errorController.close();
  }
}

/// * Instancia global del bloc de transacciones débito QR.
final transaccionQrDebitoBloc = TransaccionQrDebitoBloc();
