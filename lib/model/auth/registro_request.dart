class RegistroRequest {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String fechaNacimiento;
  final String correo;
  final String passwordHash;
  final String? numeroSerieMonedero;
  final String telefono;
  final int? idCliente;
  final String? curp;
  final String? documentacion;
  final int? estadoSolicitud;

  RegistroRequest({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.correo,
    required this.passwordHash,
    this.numeroSerieMonedero,
    required this.telefono,
    this.idCliente,
    this.curp,
    this.documentacion,
    this.estadoSolicitud,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'fechaNacimiento': fechaNacimiento,
      'correo': correo,
      'passwordHash': passwordHash,
      'telefono': telefono,
    };
    
    // Incluir numeroSerieMonedero solo si no es null y no está vacío
    if (numeroSerieMonedero != null && numeroSerieMonedero!.trim().isNotEmpty) {
      json['numeroSerieMonedero'] = numeroSerieMonedero!.trim();
    }
    
    // Incluir idCliente solo si no es null
    if (idCliente != null) {
      json['idCliente'] = idCliente;
    }
    
    // Incluir curp solo si no es null y no está vacío
    if (curp != null && curp!.trim().isNotEmpty) {
      json['curp'] = curp!.trim();
    }
    
    // Incluir documentacion solo si no es null y no está vacío
    if (documentacion != null && documentacion!.trim().isNotEmpty) {
      json['documentacion'] = documentacion!.trim();
    }
    
    // Incluir estadoSolicitud solo si no es null
    if (estadoSolicitud != null) {
      json['estadoSolicitud'] = estadoSolicitud;
    }
    
    return json;
  }
}

