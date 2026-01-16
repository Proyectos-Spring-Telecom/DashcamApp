import 'package:dashboardpro/data/datasources/extravio_remote_datasource.dart';
import 'package:dashboardpro/domain/entities/extravio_report_request.dart';
import 'package:dashboardpro/domain/entities/extravio_report_response.dart';
import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/domain/repositories/extravio_repository.dart';

class ExtravioRepositoryImpl implements ExtravioRepository {
  final ExtravioRemoteDataSource remoteDataSource;

  ExtravioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<ExtravioReportResponse>> reportarExtravio(
      ExtravioReportRequest request, String? token) async {
    try {
      final response = await remoteDataSource.reportarExtravio(
        request: request,
        token: token,
      );
      return Result.success(response);
    } on ExtravioException catch (e) {
      return Result.failure(e.message, statusCode: e.statusCode);
    } catch (_) {
      return Result.failure('Error inesperado. Intenta más tarde.');
    }
  }
}
