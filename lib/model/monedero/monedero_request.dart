class MonederoRequest {
  final String numeroSerie;
  final double saldo;
  final DateTime fechaActivacion;
  final int estatus;
  final int? idPasajero;
  final int idCliente;
  final int idTipoPasajero;
  final String idCard;

  MonederoRequest({
    required this.numeroSerie,
    required this.saldo,
    required this.fechaActivacion,
    required this.estatus,
    this.idPasajero,
    required this.idCliente,
    required this.idTipoPasajero,
    required this.idCard,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'numeroSerie': numeroSerie,
      'saldo': saldo,
      'fechaActivacion': fechaActivacion.toUtc().toIso8601String(),
      'estatus': estatus,
      'idCliente': idCliente,
      'idTipoPasajero': idTipoPasajero,
      'idCard': idCard,
    };
    
    // Incluir idPasajero solo si no es null
    if (idPasajero != null) {
      json['idPasajero'] = idPasajero;
    }
    
    return json;
  }
}

