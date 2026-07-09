import 'package:dashboardpro/services/rutas_service.dart';
import 'package:dashboardpro/model/rutas/ruta_model.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'dart:async';

/// * Estados del bloc de rutas
enum RutasStatus {
  initial,
  loading,
  loaded,
  error,
}

/// * Bloc para manejar el estado de las rutas (GET /rutas/list)
/// Gestiona la carga, estado y errores; filtra estatus === 1 y ruta != null para el dropdown
class RutasBloc {
  final RutasService _rutasService = RutasService();
  final AuthBloc _authBloc = authBloc;

  final _rutasController = StreamController<List<RutaApiModel>>.broadcast();
  final _statusController = StreamController<RutasStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  List<RutaApiModel> _rutas = [];
  RutasStatus _status = RutasStatus.initial;
  String? _errorMessage;

  List<RutaApiModel> get rutas => _rutas;
  RutasStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Stream<List<RutaApiModel>> get rutasStream => _rutasController.stream;
  Stream<RutasStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  /// * Carga las rutas desde el servicio
  /// Filtra estatus === 1 y ruta !== null para el listado del dropdown
  Future<void> cargarRutas() async {
    try {
      _status = RutasStatus.loading;
      _statusController.add(_status);
      _errorController.add(null);
      _errorMessage = null;

      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw RutasException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }


      final response = await _rutasService.obtenerRutas(token);
      // ! IMPORTANTE: Dropdown muestra todas las rutas activas (estatusRuta === 1); pintado admite solo inicio/fin si no hay polyline
      _rutas = response.rutasActivas;

      _status = RutasStatus.loaded;
      _statusController.add(_status);
      _rutasController.add(_rutas);
      _errorController.add(null);
      _errorMessage = null;

    } on RutasException catch (e) {
      _status = RutasStatus.error;
      _errorMessage = e.message;
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _rutasController.add([]);
    } catch (e, stackTrace) {
      _status = RutasStatus.error;
      _errorMessage = 'No se pudieron cargar las rutas. Intenta más tarde.';
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _rutasController.add([]);
    }
  }

  /// * Busca una ruta por id (string o int)
  RutaApiModel? rutaPorId(String id) {
    final idInt = int.tryParse(id);
    if (idInt == null) return null;
    try {
      return _rutas.firstWhere((r) => r.id == idInt);
    } catch (_) {
      return null;
    }
  }

  void limpiarError() {
    _errorMessage = null;
    _errorController.add(null);
  }

  void dispose() {
    _rutasController.close();
    _statusController.close();
    _errorController.close();
  }
}

/// * Instancia global del bloc de rutas
final rutasBloc = RutasBloc();
