import 'package:dashboardpro/data/datasources/transacciones_remote_datasource.dart';
import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/domain/repositories/transacciones_repository.dart';
import 'package:dashboardpro/model/transaccion/transaccion_model.dart';

class TransaccionesRepositoryImpl implements TransaccionesRepository {
  TransaccionesRepositoryImpl({required this.remoteDataSource});

  final TransaccionesRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<TransaccionModel>>> obtenerViajesDelDia() async {
    try {
      final list = await remoteDataSource.obtenerTransaccionesHoy();
      return Result.success(list);
    } on TransaccionesException catch (e) {
      return Result.failure(e.message, statusCode: e.statusCode);
    } catch (_) {
      return Result.failure('No fue posible obtener los viajes del día.');
    }
  }
}
