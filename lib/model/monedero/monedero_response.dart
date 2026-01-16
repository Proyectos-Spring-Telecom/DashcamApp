class MonederoResponse {
  final String status;
  final String message;
  final MonederoResponseData data;

  MonederoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MonederoResponse.fromJson(Map<String, dynamic> json) {
    return MonederoResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: MonederoResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class MonederoResponseData {
  final int id;
  final String nombre;

  MonederoResponseData({
    required this.id,
    required this.nombre,
  });

  factory MonederoResponseData.fromJson(Map<String, dynamic> json) {
    return MonederoResponseData(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

