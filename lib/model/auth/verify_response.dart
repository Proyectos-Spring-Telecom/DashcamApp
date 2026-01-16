class VerifyResponse {
  final bool success;
  final String message;
  final bool isExpired;

  VerifyResponse({
    required this.success,
    required this.message,
    this.isExpired = false,
  });

  factory VerifyResponse.fromJson(dynamic data) {
    // Si la respuesta es un String (mensaje de error del servidor)
    if (data is String) {
      final isExpired = data.contains('expirado') || 
                       data.toLowerCase().contains('expired') ||
                       data == 'El código ha expirado';
      return VerifyResponse(
        success: false,
        message: data,
        isExpired: isExpired,
      );
    }

    // Si la respuesta es un Map (JSON)
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ?? 
                     data['error']?.toString() ?? 
                     '';
      final isExpired = message.contains('expirado') || 
                       message.toLowerCase().contains('expired') ||
                       message == 'El código ha expirado';
      
      return VerifyResponse(
        success: data['success'] ?? false,
        message: message,
        isExpired: isExpired,
      );
    }

    // Respuesta por defecto
    return VerifyResponse(
      success: false,
      message: 'Error desconocido',
      isExpired: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'isExpired': isExpired,
    };
  }
}

