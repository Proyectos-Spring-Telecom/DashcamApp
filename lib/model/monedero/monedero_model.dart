class MonederoModel {
  final int id;
  final String numeroSerie;
  final double saldo;
  final DateTime? fechaActivacion;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final int estatusMonedero;
  final int? idPasajero;
  final String? pasajeroNombre;
  final String? pasajeroApellidoPaterno;
  final String? pasajeroApellidoMaterno;
  final String? nombreCompletoPasajero;
  final int? idCliente;
  final String? clienteNombre;
  final String? idCard;

  MonederoModel({
    required this.id,
    required this.numeroSerie,
    required this.saldo,
    this.fechaActivacion,
    this.fechaCreacion,
    this.fechaActualizacion,
    required this.estatusMonedero,
    this.idPasajero,
    this.pasajeroNombre,
    this.pasajeroApellidoPaterno,
    this.pasajeroApellidoMaterno,
    this.nombreCompletoPasajero,
    this.idCliente,
    this.clienteNombre,
    this.idCard,
  });

  factory MonederoModel.fromJson(Map<String, dynamic> json) {
    return MonederoModel(
      id: json['id'] as int? ?? 0,
      numeroSerie: json['numeroSerie']?.toString() ?? '',
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      fechaActivacion: json['fechaActivacion'] != null
          ? DateTime.tryParse(json['fechaActivacion'].toString())
          : null,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.tryParse(json['fechaCreacion'].toString())
          : null,
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.tryParse(json['fechaActualizacion'].toString())
          : null,
      estatusMonedero: (json['estatusMonedero'] ?? json['estatus']) as int? ?? 1,
      idPasajero: json['idPasajero'] as int?,
      pasajeroNombre: json['pasajeroNombre']?.toString(),
      pasajeroApellidoPaterno: json['pasajeroApellidoPaterno']?.toString(),
      pasajeroApellidoMaterno: json['pasajeroApellidoMaterno']?.toString(),
      nombreCompletoPasajero: json['nombreCompletoPasajero']?.toString(),
      idCliente: json['idCliente'] as int?,
      clienteNombre: json['clienteNombre']?.toString(),
      idCard: json['idCard']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroSerie': numeroSerie,
      'saldo': saldo,
      'fechaActivacion': fechaActivacion?.toIso8601String(),
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'estatusMonedero': estatusMonedero,
      'idPasajero': idPasajero,
      'pasajeroNombre': pasajeroNombre,
      'pasajeroApellidoPaterno': pasajeroApellidoPaterno,
      'pasajeroApellidoMaterno': pasajeroApellidoMaterno,
      'nombreCompletoPasajero': nombreCompletoPasajero,
      'idCliente': idCliente,
      'clienteNombre': clienteNombre,
      'idCard': idCard,
    };
  }

  /// Obtiene el nombre completo del pasajero o retorna null si no hay pasajero
  String? get nombrePasajeroCompleto {
    if (nombreCompletoPasajero != null && nombreCompletoPasajero!.isNotEmpty) {
      return nombreCompletoPasajero;
    }
    if (pasajeroNombre != null) {
      final partes = [
        pasajeroNombre,
        pasajeroApellidoPaterno,
        pasajeroApellidoMaterno,
      ].where((parte) => parte != null && parte!.isNotEmpty).toList();
      return partes.isEmpty ? null : partes.join(' ');
    }
    return null;
  }

  /// Verifica si el monedero tiene pasajero asignado
  bool get tienePasajero {
    return idPasajero != null && nombrePasajeroCompleto != null;
  }
}

