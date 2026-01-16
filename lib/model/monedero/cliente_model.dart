class ClienteModel {
  final int id;
  final String nombre;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? logotipo;

  ClienteModel({
    required this.id,
    required this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.logotipo,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellidoPaterno: json['apellidoPaterno']?.toString(),
      apellidoMaterno: json['apellidoMaterno']?.toString(),
      logotipo: json['logotipo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'logotipo': logotipo,
    };
  }

  /// Obtiene el nombre completo del cliente
  String get nombreCompleto {
    final partes = [
      nombre,
      apellidoPaterno,
      apellidoMaterno,
    ].where((parte) => parte != null && parte!.isNotEmpty).toList();
    return partes.isEmpty ? nombre : partes.join(' ');
  }
}

