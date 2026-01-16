import 'package:dashboardpro/data/datasources/cliente_remote_datasource.dart';
import 'package:dashboardpro/data/models/cliente_model.dart';
import 'package:dashboardpro/domain/entities/cliente_entity.dart';
import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/domain/repositories/cliente_repository.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteRemoteDataSource remoteDataSource;

  ClienteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<ClienteEntity>>> obtenerClientesPublicos() async {
    try {
      final clientes = await remoteDataSource.obtenerClientesPublicos();
      // Convertir modelos a entidades
      final entidades = clientes.map((cliente) => cliente as ClienteEntity).toList();
      return Result.success(entidades);
    } on ClienteException catch (e) {
      return Result.failure(e.message, statusCode: e.statusCode);
    } catch (_) {
      return Result.failure('Error inesperado. Intenta más tarde.');
    }
  }
}
