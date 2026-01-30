/// * Modelo para representar una ruta desde la API (GET /rutas/list).
/// ? INFO: Incluye puntoInicio, puntoFin y coordenadas de la polyline ([lng, lat]).
/// ! IMPORTANTE: La conversión a LatLng(lat, lng) se hace en la UI al pintar.
class RutaApiModel {
  final int id;
  final String nombre;
  final int estatus;
  /// Punto de inicio: { "lat": num, "lng": num } o similar.
  final double puntoInicioLat;
  final double puntoInicioLng;
  /// Punto de fin: { "lat": num, "lng": num } o similar.
  final double puntoFinLat;
  final double puntoFinLng;
  /// Coordenadas de la polyline: lista de [lng, lat] (GeoJSON-style).
  final List<List<double>> ruta;

  RutaApiModel({
    required this.id,
    required this.nombre,
    required this.estatus,
    required this.puntoInicioLat,
    required this.puntoInicioLng,
    required this.puntoFinLat,
    required this.puntoFinLng,
    required this.ruta,
  });

  factory RutaApiModel.fromJson(Map<String, dynamic> json) {
    // ? INFO: API usa "estatusRuta"; también aceptar "estatus" (int o string)
    int estatus = 0;
    final raw = json['estatusRuta'] ?? json['estatus'];
    if (raw != null) {
      if (raw is num) {
        estatus = raw.toInt();
      } else {
        estatus = int.tryParse(raw.toString()) ?? 0;
      }
    }

    final puntoInicio = _parsePunto(json['puntoInicio']);
    final puntoFin = _parsePunto(json['puntoFin']);
    final rutaCoords = _parseRutaCoordenadas(json['ruta']);

    return RutaApiModel(
      id: (json['id'] as num?)?.toInt() ?? int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      estatus: estatus,
      puntoInicioLat: puntoInicio.$1,
      puntoInicioLng: puntoInicio.$2,
      puntoFinLat: puntoFin.$1,
      puntoFinLng: puntoFin.$2,
      ruta: rutaCoords,
    );
  }

  /// Parsea punto como { "lat": x, "lng": y } o [lng, lat].
  static (double, double) _parsePunto(dynamic value) {
    if (value == null) return (0.0, 0.0);
    if (value is Map) {
      final m = Map<String, dynamic>.from(value as Map);
      final lat = (m['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (m['lng'] as num?)?.toDouble() ?? 0.0;
      return (lat, lng);
    }
    if (value is List && value.length >= 2) {
      final lng = (value[0] as num).toDouble();
      final lat = (value[1] as num).toDouble();
      return (lat, lng);
    }
    return (0.0, 0.0);
  }

  /// Parsea ruta: array de [lng, lat] o array de { lat, lng }.
  static List<List<double>> _parseRutaCoordenadas(dynamic value) {
    if (value == null || value is! List) return [];
    final result = <List<double>>[];
    for (final item in value) {
      if (item is List && item.length >= 2) {
        result.add([(item[0] as num).toDouble(), (item[1] as num).toDouble()]);
      } else if (item is Map) {
        final m = Map<String, dynamic>.from(item as Map);
        final lat = (m['lat'] as num?)?.toDouble() ?? 0.0;
        final lng = (m['lng'] as num?)?.toDouble() ?? 0.0;
        result.add([lng, lat]);
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'estatus': estatus,
      'puntoInicio': {'lat': puntoInicioLat, 'lng': puntoInicioLng},
      'puntoFin': {'lat': puntoFinLat, 'lng': puntoFinLng},
      'ruta': ruta,
    };
  }

  /// * Verifica si la ruta está activa (estatus === 1)
  bool get estaActiva => estatus == 1;

  /// * Verifica si tiene datos suficientes para pintar (inicio, fin y/o polyline)
  bool get tieneRutaValida {
    final hasPoints = (puntoInicioLat != 0.0 || puntoInicioLng != 0.0) &&
        (puntoFinLat != 0.0 || puntoFinLng != 0.0);
    return hasPoints || ruta.isNotEmpty;
  }
}
