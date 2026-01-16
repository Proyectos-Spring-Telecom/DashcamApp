import 'package:dashboardpro/domain/entities/cliente_entity.dart';
import 'package:dashboardpro/domain/entities/result.dart';

abstract class ClienteRepository {
  /// Obtiene la lista de clientes activos (público)
  /// No requiere autenticación
  Future<Result<List<ClienteEntity>>> obtenerClientesPublicos();
}
