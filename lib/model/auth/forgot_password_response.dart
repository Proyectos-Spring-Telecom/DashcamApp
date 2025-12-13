class ForgotPasswordResponse {
  final bool success;
  final String message;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResponse.fromJson(dynamic data) {
    // Si la respuesta es un String (mensaje del servidor)
    if (data is String) {
      return ForgotPasswordResponse(
        success: true,
        message: data,
      );
    }

    // Si la respuesta es un Map (JSON)
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ?? '';
      return ForgotPasswordResponse(
        success: data['success'] ?? true,
        message: message,
      );
    }

    // Respuesta por defecto
    return ForgotPasswordResponse(
      success: false,
      message: 'Error desconocido',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

