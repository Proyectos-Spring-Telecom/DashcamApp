/// Modelo para el request de asignar token de tarjeta a un cliente NetPay
/// Endpoint: PUT /netpay/customers/{customerId}/token
class AssignCardTokenRequest {
  final String customerId;
  final String token;
  final String? referenceId;
  final bool preAuth;
  final String cvv2;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final String telefono;
  final int? idDireccion;
  final DireccionData? direccion;

  AssignCardTokenRequest({
    required this.customerId,
    required this.token,
    this.referenceId,
    this.preAuth = false,
    required this.cvv2,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    required this.telefono,
    this.idDireccion,
    this.direccion,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'customerId': customerId,
      'token': token,
      'preAuth': preAuth,
      'cvv2': cvv2,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'email': email,
      'telefono': telefono,
    };

    if (referenceId != null && referenceId!.isNotEmpty) {
      json['referenceId'] = referenceId;
    }

    if (idDireccion != null) {
      json['idDireccion'] = idDireccion;
    }

    if (direccion != null) {
      json['direccion'] = direccion!.toJson();
    }

    return json;
  }
}

/// Modelo para los datos de dirección dentro del request
class DireccionData {
  final String ciudad;
  final String pais;
  final String cp;
  final String estado;
  final String calle;
  final String? calleEsquina;
  final String? colonia;

  DireccionData({
    required this.ciudad,
    required this.pais,
    required this.cp,
    required this.estado,
    required this.calle,
    this.calleEsquina,
    this.colonia,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'ciudad': ciudad,
      'pais': pais,
      'CP': cp,
      'estado': estado,
      'calle': calle,
    };

    if (calleEsquina != null && calleEsquina!.isNotEmpty) {
      json['calleEsquina'] = calleEsquina;
    }

    if (colonia != null && colonia!.isNotEmpty) {
      json['colonia'] = colonia;
    }

    return json;
  }
}

