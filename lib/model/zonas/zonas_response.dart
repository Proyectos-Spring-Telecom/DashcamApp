import 'package:dashboardpro/model/zonas/zona_model.dart';

/// * Modelo para la respuesta del endpoint GET /zonas/list
/// Contiene un arreglo de zonas; acepta "data", "zonas" o array directo
class ZonasResponse {
  final List<ZonaModel> data;

  ZonasResponse({
    required this.data,
  });

  factory ZonasResponse.fromJson(dynamic json) {
    List<dynamic> raw = [];
    if (json is List) {
      raw = json;
    } else if (json is Map<String, dynamic>) {
      if (json['data'] is List) {
        raw = json['data'] as List;
      } else if (json['zonas'] is List) {
        raw = json['zonas'] as List;
      }
    }

    final data = raw
        .map((e) => ZonaModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ZonasResponse(data: data);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((z) => z.toJson()).toList(),
    };
  }

  /// * Zonas activas (estatus === 1) para el dropdown
  List<ZonaModel> get zonasActivas =>
      data.where((z) => z.estaActiva).toList();

  /// * Zonas activas con geocerca válida para pintar en el mapa
  List<ZonaModel> get zonasParaMapa =>
      data.where((z) => z.estaActiva && z.tieneGeocercaValida).toList();
}
