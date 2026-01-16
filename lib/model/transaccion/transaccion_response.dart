class TransaccionResponse {
  final String status;
  final String message;
  final TransaccionData data;

  TransaccionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransaccionResponse.fromJson(Map<String, dynamic> json) {
    return TransaccionResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? TransaccionData.fromJson(json['data'] as Map<String, dynamic>)
          : TransaccionData(id: 0, nombre: ''),
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

class TransaccionData {
  final int id;
  final String nombre;

  TransaccionData({
    required this.id,
    required this.nombre,
  });

  factory TransaccionData.fromJson(Map<String, dynamic> json) {
    return TransaccionData(
      id: json['id'] as int? ?? 0,
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

