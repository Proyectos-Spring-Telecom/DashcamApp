class ChangePasswordResponse {
  final bool success;
  final String message;
  final ChangePasswordData? data;

  ChangePasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['status'] == 'success',
      message: json['message']?.toString() ?? 'Contraseña actualizada correctamente',
      data: json['data'] != null
          ? ChangePasswordData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ChangePasswordData {
  final int id;
  final String nombre;

  ChangePasswordData({
    required this.id,
    required this.nombre,
  });

  factory ChangePasswordData.fromJson(Map<String, dynamic> json) {
    return ChangePasswordData(
      id: json['id'] as int,
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

