import 'package:dashboardpro/model/rutas/ruta_model.dart';

/// * Modelo para la respuesta del endpoint GET /rutas/list.
/// Contiene un arreglo de rutas; filtrado por estatus y ruta no nula.
class RutasResponse {
  final List<RutaApiModel> data;

  RutasResponse({
    required this.data,
  });

  factory RutasResponse.fromJson(dynamic json) {
    List<dynamic> raw = [];
    if (json is List) {
      raw = json;
    } else if (json is Map<String, dynamic>) {
      if (json['data'] is List) {
        raw = json['data'] as List;
      } else if (json['rutas'] is List) {
        raw = json['rutas'] as List;
      }
    }

    final data = raw
        .map((e) => RutaApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return RutasResponse(data: data);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((r) => r.toJson()).toList(),
    };
  }

  /// * Rutas activas (estatus === 1) para el dropdown
  List<RutaApiModel> get rutasActivas =>
      data.where((r) => r.estaActiva).toList();

  /// * Rutas activas con polyline/ruta válida para pintar en el mapa
  List<RutaApiModel> get rutasParaMapa =>
      data.where((r) => r.estaActiva && r.tieneRutaValida).toList();
}
