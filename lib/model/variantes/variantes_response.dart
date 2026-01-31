import 'package:dashboardpro/model/variantes/variante_model.dart';

/// * Modelo para la respuesta del endpoint GET /variantes/list.
/// Contiene un arreglo de variantes en data[].
class VariantesResponse {
  final List<VarianteModel> data;

  VariantesResponse({required this.data});

  factory VariantesResponse.fromJson(dynamic json) {
    List<dynamic> raw = [];
    if (json is List) {
      raw = json;
    } else if (json is Map<String, dynamic>) {
      if (json['data'] is List) {
        raw = json['data'] as List;
      } else if (json['variantes'] is List) {
        raw = json['variantes'] as List;
      }
    }
    final data = raw
        .map((e) => VarianteModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return VariantesResponse(data: data);
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((v) => v.toJson()).toList(),
      };
}
