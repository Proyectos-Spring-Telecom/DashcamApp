import 'dart:async';
import 'package:dashboardpro/data/datasources/cliente_remote_datasource.dart';
import 'package:dashboardpro/data/repositories/cliente_repository_impl.dart';
import 'package:dashboardpro/domain/entities/cliente_entity.dart';
import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/domain/usecases/obtener_clientes_publicos.dart';

enum ClienteStatus { initial, loading, success, error }

class ClienteBloc {
  final _statusController = StreamController<ClienteStatus>.broadcast();
  final _clientesController = StreamController<List<ClienteEntity>>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  final ObtenerClientesPublicos _obtenerClientesPublicos;

  ClienteStatus _status = ClienteStatus.initial;
  List<ClienteEntity> _clientes = [];

  ClienteBloc()
      : _obtenerClientesPublicos = ObtenerClientesPublicos(
          ClienteRepositoryImpl(
            remoteDataSource: ClienteRemoteDataSource(),
          ),
        );

  Stream<ClienteStatus> get statusStream => _statusController.stream;
  Stream<List<ClienteEntity>> get clientesStream => _clientesController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  ClienteStatus get status => _status;
  List<ClienteEntity> get clientes => _clientes;

  /// Carga la lista de clientes activos
  Future<Result<List<ClienteEntity>>> cargarClientes() async {
    _status = ClienteStatus.loading;
    _statusController.add(_status);
    _errorController.add(null);

    final result = await _obtenerClientesPublicos();

    if (result.isSuccess) {
      _clientes = result.data ?? [];
      _status = ClienteStatus.success;
      _statusController.add(_status);
      _clientesController.add(_clientes);
    } else {
      _status = ClienteStatus.error;
      _statusController.add(_status);
      _errorController.add(result.errorMessage);
    }

    return result;
  }

  void dispose() {
    _statusController.close();
    _clientesController.close();
    _errorController.close();
  }
}

final clienteBloc = ClienteBloc();
