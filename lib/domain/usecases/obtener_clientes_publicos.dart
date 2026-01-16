import 'package:dashboardpro/domain/entities/cliente_entity.dart';
import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/domain/repositories/cliente_repository.dart';

class ObtenerClientesPublicos {
  final ClienteRepository repository;

  ObtenerClientesPublicos(this.repository);

  Future<Result<List<ClienteEntity>>> call() {
    return repository.obtenerClientesPublicos();
  }
}
