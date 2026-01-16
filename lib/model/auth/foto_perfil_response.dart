class FotoPerfilResponse {
  final String status;
  final String message;
  final FotoPerfilData? data;

  FotoPerfilResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory FotoPerfilResponse.fromJson(Map<String, dynamic> json) {
    return FotoPerfilResponse(
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString() ?? 'Error desconocido',
      data: json['data'] != null
          ? FotoPerfilData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class FotoPerfilData {
  final String id;
  final String nombre;

  FotoPerfilData({
    required this.id,
    required this.nombre,
  });

  factory FotoPerfilData.fromJson(Map<String, dynamic> json) {
    return FotoPerfilData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}

