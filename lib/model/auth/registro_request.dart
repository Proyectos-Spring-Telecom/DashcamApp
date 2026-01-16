class RegistroRequest {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String fechaNacimiento;
  final String correo;
  final String passwordHash;
  final String? numeroSerieMonedero;
  final String telefono;

  RegistroRequest({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.correo,
    required this.passwordHash,
    this.numeroSerieMonedero,
    required this.telefono,
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
    
    return json;
  }
}

