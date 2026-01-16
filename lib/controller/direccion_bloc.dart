import 'package:dashboardpro/services/direccion_service.dart';
import 'package:dashboardpro/model/direccion/codigo_postal_model.dart';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

enum DireccionStatus {
  initial,
  loading,
  loaded,
  error,
}

class DireccionBloc {
  final DireccionService _direccionService = DireccionService();
  final AuthBloc _authBloc = authBloc;

  final _codigoPostalController =
      StreamController<CodigoPostalModel?>.broadcast();
  final _statusController = StreamController<DireccionStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  Stream<CodigoPostalModel?> get codigoPostalStream =>
      _codigoPostalController.stream;
  Stream<DireccionStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  DireccionStatus _status = DireccionStatus.initial;
  CodigoPostalModel? _codigoPostal;
  String? _errorMessage;

  DireccionStatus get status => _status;
  CodigoPostalModel? get codigoPostal => _codigoPostal;
  String? get errorMessage => _errorMessage;

  DireccionBloc();

  /// Consulta información de dirección por código postal
  Future<void> consultarPorCodigoPostal(String cp) async {
    try {
      // Validar código postal antes de hacer la petición
      if (cp.isEmpty) {
        _updateError('El código postal no puede estar vacío.');
        return;
      }

      if (cp.length != 5) {
        _updateError('El código postal debe tener 5 dígitos.');
        return;
      }

      // Actualizar estado a loading
      _status = DireccionStatus.loading;
      _statusController.add(_status);
      _errorMessage = null;
      _errorController.add(_errorMessage);

      debugPrint('📍 Consultando código postal: $cp');

      // Obtener token de autenticación
      final token = _authBloc.currentToken;

      // Consultar servicio
      final response = await _direccionService.consultarPorCodigoPostal(cp, token);

      // Verificar si hay error en la respuesta
      if (response.error || response.codigoPostal == null) {
        _updateError(response.message.isNotEmpty
            ? response.message
            : 'No se encontró información para el código postal proporcionado.');
        return;
      }

      // Actualizar datos
      _codigoPostal = response.codigoPostal;
      _status = DireccionStatus.loaded;
      _errorMessage = null;

      _codigoPostalController.add(_codigoPostal);
      _statusController.add(_status);
      _errorController.add(_errorMessage);

      debugPrint('✅ Código postal consultado exitosamente');
      debugPrint('✅ Estado: ${_codigoPostal!.estado}');
      debugPrint('✅ Municipio: ${_codigoPostal!.municipio}');
      debugPrint('✅ Colonias: ${_codigoPostal!.colonias.length}');
    } catch (e) {
      debugPrint('❌ Error al consultar código postal: $e');
      _updateError(e.toString());
    }
  }

  /// Limpia el estado actual
  void reset() {
    _status = DireccionStatus.initial;
    _codigoPostal = null;
    _errorMessage = null;

    _codigoPostalController.add(_codigoPostal);
    _statusController.add(_status);
    _errorController.add(_errorMessage);
  }

  /// Actualiza el estado de error
  void _updateError(String message) {
    _status = DireccionStatus.error;
    _errorMessage = message;
    _codigoPostal = null;

    _statusController.add(_status);
    _errorController.add(_errorMessage);
    _codigoPostalController.add(_codigoPostal);
  }

  /// Libera los recursos
  void dispose() {
    _codigoPostalController.close();
    _statusController.close();
    _errorController.close();
  }
}

// Instancia global del BLoC
final direccionBloc = DireccionBloc();

