/// * Modelo para representar una zona con geocerca (GeoJSON).
/// ? INFO: La geocerca viene como FeatureCollection → features[0].geometry.coordinates.
/// ! IMPORTANTE: GeoJSON usa [lng, lat]; la conversión a LatLng(lat, lng) se hace en la UI al pintar.
class ZonaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  /// Geocerca en formato GeoJSON (FeatureCollection con Polygon).
  /// Estructura: { "type": "FeatureCollection", "features": [ { "geometry": { "coordinates": [ [ [lng, lat], ... ] ] } } ] }
  final Map<String, dynamic>? geocerca;
  final int estatus;

  ZonaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.geocerca,
    required this.estatus,
  });

  factory ZonaModel.fromJson(Map<String, dynamic> json) {
    // ? INFO: estatus puede venir como int 1 o string "1"; nombre ej. "TEMIXCO"
    int estatus = 0;
    if (json['estatus'] != null) {
      if (json['estatus'] is num) {
        estatus = (json['estatus'] as num).toInt();
      } else {
        estatus = int.tryParse(json['estatus'].toString()) ?? 0;
      }
    }
    return ZonaModel(
      id: (json['id'] as num?)?.toInt() ?? int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      geocerca: json['geocerca'] is Map<String, dynamic>
          ? json['geocerca'] as Map<String, dynamic>
          : (json['geocerca'] is Map ? Map<String, dynamic>.from(json['geocerca'] as Map) : null),
      estatus: estatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'geocerca': geocerca,
      'estatus': estatus,
    };
  }

  /// * Verifica si la zona está activa (estatus === 1)
  bool get estaActiva => estatus == 1;

  /// * Verifica si la zona tiene geocerca válida para pintar
  /// ? INFO: Acepta FeatureCollection (features[0].geometry) o Feature (geometry directo)
  bool get tieneGeocercaValida {
    if (geocerca == null) return false;
    final geometry = _getGeometryFromGeocerca(geocerca!);
    if (geometry == null) return false;
    final coords = geometry['coordinates'];
    return coords is List && coords.isNotEmpty;
  }

  /// * Obtiene el mapa geometry desde geocerca (FeatureCollection o Feature)
  static Map<String, dynamic>? _getGeometryFromGeocerca(Map<String, dynamic> geocerca) {
    // FeatureCollection: { "features": [ { "geometry": { ... } } ] }
    final features = geocerca['features'];
    if (features is List && features.isNotEmpty) {
      final first = features.first;
      if (first is Map<String, dynamic>) {
        final geometry = first['geometry'];
        if (geometry is Map<String, dynamic>) return geometry;
      }
    }
    // Feature: { "geometry": { ... } }
    final geometry = geocerca['geometry'];
    if (geometry is Map<String, dynamic>) return geometry;
    return null;
  }

  /// * Obtiene las coordenadas del anillo exterior del polígono (GeoJSON: [lng, lat] por punto).
  /// ? INFO: geometry.coordinates[0] = anillo exterior en GeoJSON Polygon.
  /// Retorna lista de [lng, lat] para que la UI convierta a LatLng(lat, lng).
  List<List<double>> getExteriorRingCoordinates() {
    if (geocerca == null) return [];
    final geometry = _getGeometryFromGeocerca(geocerca!);
    if (geometry == null) return [];
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) return [];
    // Polygon: coordinates[0] = exterior ring = List of [lng, lat]
    final ring = coordinates[0] is List ? coordinates[0] as List : <dynamic>[];
    final result = <List<double>>[];
    for (final point in ring) {
      if (point is List && point.length >= 2) {
        final lng = (point[0] as num).toDouble();
        final lat = (point[1] as num).toDouble();
        result.add([lng, lat]);
      }
    }
    return result;
  }
}
