import 'package:dashboardpro/model/variantes/estacion_model.dart';

/// * Modelo para una variante desde la API (GET /variantes/list).
/// ? INFO: puntoInicio/puntoFin con coordenadas; recorridoDetallado = estaciones.
/// ! IMPORTANTE: La conversión a LatLng se hace en la UI al pintar.
class VarianteModel {
  final int id;
  final String nombreVariante;
  final double puntoInicioLat;
  final double puntoInicioLng;
  final double puntoFinLat;
  final double puntoFinLng;
  final List<EstacionModel> recorridoDetallado;

  VarianteModel({
    required this.id,
    required this.nombreVariante,
    required this.puntoInicioLat,
    required this.puntoInicioLng,
    required this.puntoFinLat,
    required this.puntoFinLng,
    required this.recorridoDetallado,
  });

  /// Parsea punto: { "coordenadas": { "lat", "lng" } } o { "lat", "lng" } directo.
  static (double, double) _parsePunto(dynamic value) {
    if (value == null) return (0.0, 0.0);
    if (value is Map) {
      final m = Map<String, dynamic>.from(value as Map);
      final coords = m['coordenadas'];
      if (coords is Map) {
        final c = Map<String, dynamic>.from(coords as Map);
        final lat = (c['lat'] as num?)?.toDouble() ?? 0.0;
        final lng = (c['lng'] as num?)?.toDouble() ?? 0.0;
        return (lat, lng);
      }
      final lat = (m['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (m['lng'] as num?)?.toDouble() ?? 0.0;
      return (lat, lng);
    }
    return (0.0, 0.0);
  }

  factory VarianteModel.fromJson(Map<String, dynamic> json) {
    final inicio = _parsePunto(json['puntoInicio']);
    final fin = _parsePunto(json['puntoFin']);
    List<EstacionModel> recorrido = [];
    final raw = json['recorridoDetallado'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          recorrido.add(EstacionModel.fromJson(Map<String, dynamic>.from(e as Map)));
        }
      }
    }
    return VarianteModel(
      id: (json['id'] as num?)?.toInt() ?? int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombreVariante: json['nombreVariante']?.toString() ?? '',
      puntoInicioLat: inicio.$1,
      puntoInicioLng: inicio.$2,
      puntoFinLat: fin.$1,
      puntoFinLng: fin.$2,
      recorridoDetallado: recorrido,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombreVariante': nombreVariante,
        'puntoInicio': {'coordenadas': {'lat': puntoInicioLat, 'lng': puntoInicioLng}},
        'puntoFin': {'coordenadas': {'lat': puntoFinLat, 'lng': puntoFinLng}},
        'recorridoDetallado': recorridoDetallado.map((e) => e.toJson()).toList(),
      };

  /// * Verifica si tiene datos suficientes para pintar (inicio, fin y/o estaciones).
  bool get tieneRecorridoValido {
    final hasExtremos = (puntoInicioLat != 0.0 || puntoInicioLng != 0.0) &&
        (puntoFinLat != 0.0 || puntoFinLng != 0.0);
    return hasExtremos || recorridoDetallado.isNotEmpty;
  }
}
