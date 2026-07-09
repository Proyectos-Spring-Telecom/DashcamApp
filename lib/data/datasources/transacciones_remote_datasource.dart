import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';
import 'package:dashboardpro/services/monedero_service.dart';
import 'package:intl/intl.dart';

/// Fuente de datos remota para transacciones.
/// Reutiliza [MonederoService] y el endpoint POST /transacciones/paginado.
class TransaccionesRemoteDataSource {
  TransaccionesRemoteDataSource({
    required MonederoService monederoService,
    required AuthBloc authBloc,
  })  : _monederoService = monederoService,
        _authBloc = authBloc;

  final MonederoService _monederoService;
  final AuthBloc _authBloc;

  /// Obtiene las transacciones del día actual (máximo 10).
  /// Usa POST /transacciones/paginado con fechaInicio = fechaFin = hoy.
  /// 201 → lista de [TransaccionModel]; 400/500 o error de red → lanza [TransaccionesException].
  Future<List<TransaccionModel>> obtenerTransaccionesHoy() async {
    final now = DateTime.now();
    final fecha = DateFormat('yyyy-MM-dd').format(now);
    final token = _authBloc.currentToken;

    if (token == null || token.isEmpty) {
      throw TransaccionesException(
        message: 'No hay sesión activa. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }

    try {
      final response = await _monederoService.obtenerListaTransacciones(
        token: token,
        page: 1,
        limit: 10,
        fechaInicio: fecha,
        fechaFin: fecha,
      );

      final data = response.data;
      final statusCode = 201; // El servicio ya validó 200/201
      return data;
    } on MonederoException catch (e) {
      throw TransaccionesException(message: e.message);
    } catch (e, st) {
      throw TransaccionesException(
        message: 'No fue posible obtener los viajes del día. Intenta más tarde.',
      );
    }
  }
}

class TransaccionesException implements Exception {
  final String message;
  final int? statusCode;

  TransaccionesException({required this.message, this.statusCode});
}
