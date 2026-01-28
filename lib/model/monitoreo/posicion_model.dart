/// * Modelo para representar la posición geográfica de una unidad
/// Contiene coordenadas de latitud y longitud
class PosicionModel {
  final double lat;
  final double lng;

  PosicionModel({
    required this.lat,
    required this.lng,
  });

  factory PosicionModel.fromJson(Map<String, dynamic> json) {
    return PosicionModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  /// * Verifica si la posición es válida (coordenadas dentro de rangos válidos)
  bool get esValida {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }
}
