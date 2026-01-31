import 'package:dashboardpro/services/variantes_service.dart';
import 'package:dashboardpro/model/variantes/variante_model.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// * Estados del bloc de variantes
enum VariantesStatus {
  initial,
  loading,
  loaded,
  error,
}

/// * Bloc para manejar el estado de las variantes (GET /variantes/list)
/// Gestiona la carga, estado y errores; no acopla con zonas ni unidades.
class VariantesBloc {
  final VariantesService _variantesService = VariantesService();
  final AuthBloc _authBloc = authBloc;

  final _variantesController = StreamController<List<VarianteModel>>.broadcast();
  final _statusController = StreamController<VariantesStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  List<VarianteModel> _variantes = [];
  VariantesStatus _status = VariantesStatus.initial;
  String? _errorMessage;

  List<VarianteModel> get variantes => _variantes;
  VariantesStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Stream<List<VarianteModel>> get variantesStream => _variantesController.stream;
  Stream<VariantesStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  /// * Carga las variantes desde el servicio
  Future<void> cargarVariantes() async {
    try {
      _status = VariantesStatus.loading;
      _statusController.add(_status);
      _errorController.add(null);
      _errorMessage = null;

      final token = _authBloc.currentToken;
      if (token == null || token.isEmpty) {
        throw VariantesException(
            'No hay sesión activa. Por favor, inicia sesión nuevamente.');
      }

      debugPrint('📤 Cargando variantes...');

      final response = await _variantesService.obtenerVariantes(token);
      _variantes = response.data;

      _status = VariantesStatus.loaded;
      _statusController.add(_status);
      _variantesController.add(_variantes);
      _errorController.add(null);
      _errorMessage = null;

      debugPrint('✅ Variantes cargadas exitosamente');
      debugPrint('✅ Total de variantes: ${_variantes.length}');
    } on VariantesException catch (e) {
      debugPrint('❌ VariantesException en cargarVariantes: ${e.message}');
      _status = VariantesStatus.error;
      _errorMessage = e.message;
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _variantesController.add([]);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en cargarVariantes: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _status = VariantesStatus.error;
      _errorMessage = 'No fue posible cargar las variantes. Intenta más tarde.';
      _statusController.add(_status);
      _errorController.add(_errorMessage);
      _variantesController.add([]);
    }
  }

  /// * Busca una variante por id (string o int)
  VarianteModel? variantePorId(String id) {
    final idInt = int.tryParse(id);
    if (idInt == null) return null;
    try {
      return _variantes.firstWhere((v) => v.id == idInt);
    } catch (_) {
      return null;
    }
  }

  void limpiarError() {
    _errorMessage = null;
    _errorController.add(null);
  }

  void dispose() {
    _variantesController.close();
    _statusController.close();
    _errorController.close();
  }
}

/// * Instancia global del bloc de variantes
final variantesBloc = VariantesBloc();
