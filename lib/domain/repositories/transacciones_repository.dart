import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';

abstract class TransaccionesRepository {
  /// Obtiene los viajes (transacciones) del día actual (máximo 10).
  /// Delega al datasource que consume POST /transacciones/paginado.
  Future<Result<List<TransaccionModel>>> obtenerViajesDelDia();
}
