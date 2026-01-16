import 'package:dashboardpro/domain/entities/extravio_report_request.dart';
import 'package:dashboardpro/domain/entities/extravio_report_response.dart';
import 'package:dashboardpro/domain/entities/result.dart';

abstract class ExtravioRepository {
  Future<Result<ExtravioReportResponse>> reportarExtravio(
    ExtravioReportRequest request,
    String? token,
  );
}
