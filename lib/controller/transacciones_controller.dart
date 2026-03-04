import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/data/datasources/transacciones_remote_datasource.dart';
import 'package:dashboardpro/data/repositories/transacciones_repository_impl.dart';
import 'package:dashboardpro/domain/repositories/transacciones_repository.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';
import 'package:dashboardpro/services/monedero_service.dart';
import 'package:flutter/foundation.dart';

enum ViajesDelDiaStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

/// Controller para la lista de viajes del día (transacciones del día actual).
/// Reutiliza POST /transacciones/paginado vía [TransaccionesRepository].
class TransaccionesController extends ChangeNotifier {
  TransaccionesController({
    TransaccionesRepository? repository,
  }) : _repository = repository ?? _defaultRepository;

  static final TransaccionesRepository _defaultRepository =
      TransaccionesRepositoryImpl(
    remoteDataSource: TransaccionesRemoteDataSource(
      monederoService: MonederoService(),
      authBloc: authBloc,
    ),
  );

  final TransaccionesRepository _repository;

  ViajesDelDiaStatus _status = ViajesDelDiaStatus.initial;
  List<TransaccionModel> _viajes = [];
  String? _errorMessage;

  ViajesDelDiaStatus get status => _status;
  List<TransaccionModel> get viajes => List.unmodifiable(_viajes);
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ViajesDelDiaStatus.loading;
  bool get isSuccess => _status == ViajesDelDiaStatus.success;
  bool get isEmpty => _status == ViajesDelDiaStatus.empty;
  bool get isError => _status == ViajesDelDiaStatus.error;

  /// Carga los viajes del día actual (máximo 10).
  /// Estados: loading → success | empty | error.
  Future<void> cargarViajesDelDia() async {
    debugPrint('📤 [ViajesDelDia] Inicio cargarViajesDelDia');
    _status = ViajesDelDiaStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.obtenerViajesDelDia();

      if (result.isSuccess && result.data != null) {
        final list = result.data!;
        debugPrint('📥 [ViajesDelDia] Viajes obtenidos: ${list.length}');
        _viajes = list;
        if (list.isEmpty) {
          _status = ViajesDelDiaStatus.empty;
          debugPrint('📥 [ViajesDelDia] Estado: empty (sin viajes hoy)');
        } else {
          _status = ViajesDelDiaStatus.success;
          debugPrint('📥 [ViajesDelDia] Estado: success');
        }
      } else {
        _status = ViajesDelDiaStatus.error;
        _errorMessage = result.errorMessage ?? 'No fue posible obtener los viajes del día.';
        debugPrint('❌ [ViajesDelDia] Error: $_errorMessage');
      }
    } catch (e, st) {
      debugPrint('❌ [ViajesDelDia] Excepción: $e');
      debugPrint('❌ [ViajesDelDia] Stack: $st');
      _status = ViajesDelDiaStatus.error;
      _errorMessage = 'No fue posible obtener los viajes del día.';
    }
    notifyListeners();
  }

  /// Devuelve el viaje por [id] de la lista ya cargada (no llama al servicio).
  TransaccionModel? viajePorId(int id) {
    try {
      return _viajes.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Instancia global para usar en la UI (BottomSheet Viajes y botón Detalle).
final transaccionesController = TransaccionesController();
