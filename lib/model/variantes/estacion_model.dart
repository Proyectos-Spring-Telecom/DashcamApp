/// * Modelo para una estación (punto intermedio) en el recorrido de una variante.
/// ? INFO: recorridoDetallado[] en la API; opcionalmente incluye nombre para InfoWindow.
class EstacionModel {
  final double lat;
  final double lng;
  final String? nombre;

  EstacionModel({
    required this.lat,
    required this.lng,
    this.nombre,
  });

  factory EstacionModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0, lng = 0.0;
    if (json['coordenadas'] is Map) {
      final c = Map<String, dynamic>.from(json['coordenadas'] as Map);
      lat = (c['lat'] as num?)?.toDouble() ?? 0.0;
      lng = (c['lng'] as num?)?.toDouble() ?? 0.0;
    } else {
      lat = (json['lat'] as num?)?.toDouble() ?? 0.0;
      lng = (json['lng'] as num?)?.toDouble() ?? 0.0;
    }
    return EstacionModel(
      lat: lat,
      lng: lng,
      nombre: json['nombre']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        if (nombre != null) 'nombre': nombre,
      };
}
