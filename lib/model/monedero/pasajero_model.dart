class PasajeroModel {
  final int id;
  final String nombre;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? correo;
  final String? numeroSerie;

  PasajeroModel({
    required this.id,
    required this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.correo,
    this.numeroSerie,
  });

  factory PasajeroModel.fromJson(Map<String, dynamic> json) {
    return PasajeroModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellidoPaterno: json['apellidoPaterno']?.toString(),
      apellidoMaterno: json['apellidoMaterno']?.toString(),
      correo: json['correo']?.toString(),
      numeroSerie: json['numeroSerie']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'correo': correo,
      'numeroSerie': numeroSerie,
    };
  }

  /// Obtiene el nombre completo del pasajero
  String get nombreCompleto {
    final partes = [
      nombre,
      apellidoPaterno,
      apellidoMaterno,
    ].where((parte) => parte != null && parte!.isNotEmpty).toList();
    return partes.isEmpty ? nombre : partes.join(' ');
  }
}

