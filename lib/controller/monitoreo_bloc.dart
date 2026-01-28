import 'package:dashboardpro/services/monitoreo_service.dart';
import 'package:dashboardpro/model/monitoreo/unidad_model.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// * Estados del bloc de monitoreo
enum MonitoreoStatus {
  initial,
  loading,
  loaded,
  error,
}

/// * Bloc para manejar el estado de las unidades de monitoreo
/// Gestiona la carga, estado y errores de las unidades
class MonitoreoBloc {
  final MonitoreoService _monitoreoService = MonitoreoService();
  final AuthBloc _authBloc = authBloc;

  // * Streams para el estado de las unidades
  final _unidadesController = StreamController<List<UnidadModel>>.broadcast();
  final _statusController = StreamController<MonitoreoStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  // * Estado actual
  List<UnidadModel> _unidades = [];
  MonitoreoStatus _status = MonitoreoStatus.initial;
  String? _errorMessage;

  // * Getters para acceder al estado actual
  List<UnidadModel> get unidades => _unidades;
  MonitoreoStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // * Streams públicos
  Stream<List<UnidadModel>> get unidadesStream => _unidadesController.stream;
  Stream<MonitoreoStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  /// * Carga las unidades desde el servicio
  /// Filtra automáticamente por cliente del token autenticado y clientes hijos
  Future<void> cargarUnidades() async {
    try {
      // * Actualizar estado a loading
      _status = MonitoreoStatus.loading;
      _statusController.add(_status);
      _errorController.add(null);
      _errorMessage = null;

      // * Obtener el token del AuthBloc
      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw MonitoreoException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Cargando unidades de monitoreo...');

      // * Llamar al servicio
      final response = await _monitoreoService.obtenerUnidades(token);

      // * Actualizar estado con las unidades obtenidas
      _unidades = response.data;
      _status = MonitoreoStatus.loaded;
      _statusController.add(_status);
      _unidadesController.add(_unidades);
      _errorController.add(null);
      _errorMessage = null;

      debugPrint('✅ Unidades cargadas exitosamente');
      debugPrint('✅ Total de unidades: ${_unidades.length}');
      debugPrint('✅ Unidades con posición válida: ${response.unidadesConPosicionValida.length}');
    } on MonitoreoException catch (e) {
      debugPrint('❌ MonitoreoException en cargarUnidades: ${e.message}');
      _status = MonitoreoStatus.error;
      _errorMessage = e.message;
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _unidadesController.add([]);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en cargarUnidades: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _status = MonitoreoStatus.error;
      _errorMessage = 'No se pudieron cargar las unidades. Intenta más tarde.';
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _unidadesController.add([]);
    }
  }

  /// * Obtiene solo las unidades con posición válida
  List<UnidadModel> get unidadesConPosicionValida {
    return _unidades.where((unidad) => unidad.tienePosicionValida).toList();
  }

  /// * Obtiene solo las unidades en ruta
  List<UnidadModel> get unidadesEnRuta {
    return _unidades.where((unidad) => unidad.estaEnRuta).toList();
  }

  /// * Limpia el estado de error
  void limpiarError() {
    _errorMessage = null;
    _errorController.add(null);
  }

  /// * Dispose de los streams
  void dispose() {
    _unidadesController.close();
    _statusController.close();
    _errorController.close();
  }
}

/// * Instancia global del bloc de monitoreo
final monitoreoBloc = MonitoreoBloc();
