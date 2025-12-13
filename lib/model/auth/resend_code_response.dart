class ResendCodeResponse {
  final bool success;
  final String message;

  ResendCodeResponse({
    required this.success,
    required this.message,
  });

  factory ResendCodeResponse.fromJson(dynamic data) {
    // Si la respuesta es un String (mensaje del servidor)
    if (data is String) {
      return ResendCodeResponse(
        success: true,
        message: data,
      );
    }

    // Si la respuesta es un Map (JSON)
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ?? '';
      return ResendCodeResponse(
        success: data['success'] ?? true,
        message: message,
      );
    }

    // Respuesta por defecto
    return ResendCodeResponse(
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

