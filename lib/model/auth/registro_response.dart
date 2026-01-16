class RegistroResponse {
  final String status;
  final String message;
  final RegistroData data;

  RegistroResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RegistroResponse.fromJson(Map<String, dynamic> json) {
    // Manejar el caso donde data puede ser null o tener una estructura diferente
    RegistroData registroData;
    try {
      if (json['data'] != null && json['data'] is Map<String, dynamic>) {
        registroData = RegistroData.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        // Si data es null o no es un Map, intentar obtener valores del nivel raíz
        final dataMap = json['data'] is Map<String, dynamic> 
            ? json['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        
        registroData = RegistroData(
          id: dataMap['id'] ?? json['id'] ?? 0,
          nombre: dataMap['nombre']?.toString() ?? json['nombre']?.toString() ?? '',
        );
      }
    } catch (e) {
      // Si hay un error al parsear data, usar valores por defecto
      registroData = RegistroData(
        id: json['id'] ?? 0,
        nombre: json['nombre']?.toString() ?? '',
      );
    }

    return RegistroResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: registroData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class RegistroData {
  final int id;
  final String nombre;

  RegistroData({
    required this.id,
    required this.nombre,
  });

  factory RegistroData.fromJson(Map<String, dynamic> json) {
    return RegistroData(
      id: json['id'] ?? 0,
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

