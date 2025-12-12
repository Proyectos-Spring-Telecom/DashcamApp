class RegistroRequest {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String fechaNacimiento;
  final String correo;
  final String passwordHash;
  final String numeroSerieMonedero;
  final String telefono;

  RegistroRequest({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.correo,
    required this.passwordHash,
    required this.numeroSerieMonedero,
    required this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'fechaNacimiento': fechaNacimiento,
      'correo': correo,
      'passwordHash': passwordHash,
      'numeroSerieMonedero': numeroSerieMonedero,
      'telefono': telefono,
    };
  }
}

