import 'package:dashboardpro/services/zonas_service.dart';
import 'package:dashboardpro/model/zonas/zona_model.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// * Estados del bloc de zonas
enum ZonasStatus {
  initial,
  loading,
  loaded,
  error,
}

/// * Bloc para manejar el estado de las zonas (GET /zonas/list)
/// Gestiona la carga, estado y errores; filtra estatus === 1 para el dropdown
class ZonasBloc {
  final ZonasService _zonasService = ZonasService();
  final AuthBloc _authBloc = authBloc;

  final _zonasController = StreamController<List<ZonaModel>>.broadcast();
  final _statusController = StreamController<ZonasStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  List<ZonaModel> _zonas = [];
  ZonasStatus _status = ZonasStatus.initial;
  String? _errorMessage;

  List<ZonaModel> get zonas => _zonas;
  ZonasStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Stream<List<ZonaModel>> get zonasStream => _zonasController.stream;
  Stream<ZonasStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  /// * Carga las zonas desde el servicio
  /// Filtra estatus === 1 para el listado del dropdown
  Future<void> cargarZonas() async {
    try {
      _status = ZonasStatus.loading;
      _statusController.add(_status);
      _errorController.add(null);
      _errorMessage = null;

      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw ZonasException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Cargando zonas...');

      final response = await _zonasService.obtenerZonas(token);
      _zonas = response.zonasActivas;

      _status = ZonasStatus.loaded;
      _statusController.add(_status);
      _zonasController.add(_zonas);
      _errorController.add(null);
      _errorMessage = null;

      debugPrint('✅ Zonas cargadas exitosamente');
      debugPrint('✅ Total de zonas (dropdown): ${_zonas.length}');
    } on ZonasException catch (e) {
      debugPrint('❌ ZonasException en cargarZonas: ${e.message}');
      _status = ZonasStatus.error;
      _errorMessage = e.message;
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _zonasController.add([]);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en cargarZonas: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _status = ZonasStatus.error;
      _errorMessage = 'No se pudieron cargar las zonas. Intenta más tarde.';
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _zonasController.add([]);
    }
  }

  /// * Busca una zona por id (string o int)
  ZonaModel? zonaPorId(String id) {
    final idInt = int.tryParse(id);
    if (idInt == null) return null;
    try {
      return _zonas.firstWhere((z) => z.id == idInt);
    } catch (_) {
      return null;
    }
  }

  void limpiarError() {
    _errorMessage = null;
    _errorController.add(null);
  }

  void dispose() {
    _zonasController.close();
    _statusController.close();
    _errorController.close();
  }
}

/// * Instancia global del bloc de zonas
final zonasBloc = ZonasBloc();
