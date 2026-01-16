import 'dart:async';
import 'package:dashboardpro/controller/auth_bloc.dart';
import 'package:dashboardpro/data/datasources/extravio_remote_datasource.dart';
import 'package:dashboardpro/data/repositories/extravio_repository_impl.dart';
import 'package:dashboardpro/domain/entities/extravio_report_response.dart';
import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/domain/usecases/reportar_extravio.dart';

enum ExtravioStatus { initial, loading, success, error }

class ExtravioBloc {
  final _statusController = StreamController<ExtravioStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();
  final _responseController =
      StreamController<ExtravioReportResponse?>.broadcast();

  final ReportarExtravio _reportarExtravio;
  final AuthBloc _authBloc = authBloc;

  ExtravioStatus _status = ExtravioStatus.initial;

  ExtravioBloc()
      : _reportarExtravio = ReportarExtravio(
          ExtravioRepositoryImpl(
            remoteDataSource: ExtravioRemoteDataSource(),
          ),
        );

  Stream<ExtravioStatus> get statusStream => _statusController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  Stream<ExtravioReportResponse?> get responseStream =>
      _responseController.stream;

  ExtravioStatus get status => _status;

  Future<Result<ExtravioReportResponse>> reportarExtravio({
    required String numeroSerie,
  }) async {
    final correo = _authBloc.currentUser?.userName;
    if (correo == null || correo.isEmpty) {
      _status = ExtravioStatus.error;
      _statusController.add(_status);
      _errorController.add('No se pudo obtener el correo del usuario.');
      return Result.failure('No se pudo obtener el correo del usuario.');
    }

    final token = _authBloc.currentToken;
    if (token == null || token.isEmpty) {
      _status = ExtravioStatus.error;
      _statusController.add(_status);
      _errorController.add('No hay sesión activa. Por favor, inicia sesión nuevamente.');
      return Result.failure('No hay sesión activa. Por favor, inicia sesión nuevamente.');
    }

    _status = ExtravioStatus.loading;
    _statusController.add(_status);
    _errorController.add(null);

    final result = await _reportarExtravio(
      correo: correo,
      numeroSerie: numeroSerie,
      token: token,
    );

    if (result.isSuccess) {
      _status = ExtravioStatus.success;
      _statusController.add(_status);
      _responseController.add(result.data);
    } else {
      _status = ExtravioStatus.error;
      _statusController.add(_status);
      _errorController.add(result.errorMessage);
    }

    return result;
  }

  void dispose() {
    _statusController.close();
    _errorController.close();
    _responseController.close();
  }
}

final extravioBloc = ExtravioBloc();
