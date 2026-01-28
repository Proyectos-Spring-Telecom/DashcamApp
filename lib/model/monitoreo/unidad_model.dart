import 'package:dashboardpro/model/monitoreo/posicion_model.dart';

/// * Modelo para representar una unidad (vehículo) en el sistema de monitoreo
/// Contiene toda la información de la unidad incluyendo posición, estado, conductor, etc.
class UnidadModel {
  final int id;
  final String codigo;
  final String modelo;
  final String conductor;
  final String ultimoPing;
  final String velocidad;
  final String estado; // * "ruta", "detenido", etc.
  final PosicionModel posicion;
  final String numeroSerieValidador;
  final int idInstalacion;
  final int idTurno;
  final int turnoEstatus;
  final DateTime? turnoInicio;
  final DateTime? turnoFin;
  final int? idViaje;
  final int? viajeEstatus;
  final DateTime? viajeInicio;
  final DateTime? viajeFin;
  final int? idVariante;
  final String? nombreVariante;
  final int sumSubidas;
  final int sumBajadas;
  final int diferencia;

  UnidadModel({
    required this.id,
    required this.codigo,
    required this.modelo,
    required this.conductor,
    required this.ultimoPing,
    required this.velocidad,
    required this.estado,
    required this.posicion,
    required this.numeroSerieValidador,
    required this.idInstalacion,
    required this.idTurno,
    required this.turnoEstatus,
    this.turnoInicio,
    this.turnoFin,
    this.idViaje,
    this.viajeEstatus,
    this.viajeInicio,
    this.viajeFin,
    this.idVariante,
    this.nombreVariante,
    required this.sumSubidas,
    required this.sumBajadas,
    required this.diferencia,
  });

  factory UnidadModel.fromJson(Map<String, dynamic> json) {
    return UnidadModel(
      id: json['id'] as int? ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      conductor: json['conductor']?.toString() ?? '',
      ultimoPing: json['ultimoPing']?.toString() ?? '',
      velocidad: json['velocidad']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      posicion: json['posicion'] != null
          ? PosicionModel.fromJson(json['posicion'] as Map<String, dynamic>)
          : PosicionModel(lat: 0.0, lng: 0.0), // * Fallback si no hay posición
      numeroSerieValidador: json['numeroSerieValidador']?.toString() ?? '',
      idInstalacion: json['idInstalacion'] as int? ?? 0,
      idTurno: json['idTurno'] as int? ?? 0,
      turnoEstatus: json['turnoEstatus'] as int? ?? 0,
      turnoInicio: json['turnoInicio'] != null
          ? DateTime.tryParse(json['turnoInicio'].toString())
          : null,
      turnoFin: json['turnoFin'] != null
          ? DateTime.tryParse(json['turnoFin'].toString())
          : null,
      idViaje: json['idViaje'] as int?,
      viajeEstatus: json['viajeEstatus'] as int?,
      viajeInicio: json['viajeInicio'] != null
          ? DateTime.tryParse(json['viajeInicio'].toString())
          : null,
      viajeFin: json['viajeFin'] != null
          ? DateTime.tryParse(json['viajeFin'].toString())
          : null,
      idVariante: json['idVariante'] as int?,
      nombreVariante: json['nombreVariante']?.toString(),
      sumSubidas: json['sumSubidas'] as int? ?? 0,
      sumBajadas: json['sumBajadas'] as int? ?? 0,
      diferencia: json['diferencia'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'modelo': modelo,
      'conductor': conductor,
      'ultimoPing': ultimoPing,
      'velocidad': velocidad,
      'estado': estado,
      'posicion': posicion.toJson(),
      'numeroSerieValidador': numeroSerieValidador,
      'idInstalacion': idInstalacion,
      'idTurno': idTurno,
      'turnoEstatus': turnoEstatus,
      'turnoInicio': turnoInicio?.toIso8601String(),
      'turnoFin': turnoFin?.toIso8601String(),
      'idViaje': idViaje,
      'viajeEstatus': viajeEstatus,
      'viajeInicio': viajeInicio?.toIso8601String(),
      'viajeFin': viajeFin?.toIso8601String(),
      'idVariante': idVariante,
      'nombreVariante': nombreVariante,
      'sumSubidas': sumSubidas,
      'sumBajadas': sumBajadas,
      'diferencia': diferencia,
    };
  }

  /// * Verifica si la unidad tiene una posición válida
  bool get tienePosicionValida => posicion.esValida;

  /// * Verifica si la unidad está en ruta
  bool get estaEnRuta => estado.toLowerCase() == 'ruta';

  /// * Obtiene el nombre completo de la variante o un valor por defecto
  String get nombreVarianteDisplay => nombreVariante ?? 'Sin variante';
}
