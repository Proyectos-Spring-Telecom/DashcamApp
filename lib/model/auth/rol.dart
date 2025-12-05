class Rol {
  final String id;
  final String nombre;
  final String descripcion;
  final String? fechaCreacion;
  final String? fechaActualizacion;
  final int estatus;

  Rol({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.fechaCreacion,
    this.fechaActualizacion,
    required this.estatus,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fechaCreacion: json['fechaCreacion']?.toString(),
      fechaActualizacion: json['fechaActualizacion']?.toString(),
      estatus: json['estatus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
      'estatus': estatus,
    };
  }
}

