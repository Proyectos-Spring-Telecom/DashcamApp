import 'package:dashboardpro/domain/entities/extravio_report_request.dart';
import 'package:dashboardpro/domain/entities/extravio_report_response.dart';
import 'package:dashboardpro/domain/entities/result.dart';
import 'package:dashboardpro/domain/repositories/extravio_repository.dart';

class ReportarExtravio {
  final ExtravioRepository repository;

  ReportarExtravio(this.repository);

  Future<Result<ExtravioReportResponse>> call({
    required String correo,
    required String numeroSerie,
    String? token,
  }) {
    final request = ExtravioReportRequest(
      correo: correo,
      numeroSerie: numeroSerie,
    );
    return repository.reportarExtravio(request, token);
  }
}
