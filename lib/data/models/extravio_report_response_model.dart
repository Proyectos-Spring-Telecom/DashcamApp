import 'package:dashboardpro/domain/entities/extravio_report_response.dart';

class ExtravioReportResponseModel extends ExtravioReportResponse {
  ExtravioReportResponseModel({
    required super.message,
    super.status,
  });

  factory ExtravioReportResponseModel.fromJson(Map<String, dynamic> json) {
    return ExtravioReportResponseModel(
      message: json['message']?.toString() ??
          json['mensaje']?.toString() ??
          'Reporte enviado correctamente.',
      status: json['status']?.toString(),
    );
  }
}
