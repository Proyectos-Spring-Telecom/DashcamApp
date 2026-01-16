/// Modelo para la respuesta de tokenización de NetPay
class CardTokenResponse {
  /// Token de la tarjeta (este es el único dato que debe persistirse)
  final String token;
  
  /// Tipo de tarjeta (Visa, MasterCard, etc.)
  final String? cardType;
  
  /// Últimos 4 dígitos de la tarjeta (para mostrar al usuario)
  final String? last4Digits;
  
  /// Marca de la tarjeta (opcional)
  final String? brand;
  
  /// Si la tarjeta fue guardada exitosamente
  final bool success;
  
  /// Mensaje de respuesta (si existe)
  final String? message;

  CardTokenResponse({
    required this.token,
    this.cardType,
    this.last4Digits,
    this.brand,
    required this.success,
    this.message,
  });

  /// Crea una respuesta desde JSON de NetPay
  factory CardTokenResponse.fromJson(Map<String, dynamic> json) {
    // Determinar si fue exitoso
    final bool isSuccess;
    if (json['success'] != null) {
      isSuccess = json['success'] as bool;
    } else if (json['status'] != null) {
      isSuccess = (json['status'] as String?) == 'success';
    } else {
      // Si no hay indicador de éxito, asumir que fue exitoso si hay token
      isSuccess = (json['token'] != null || json['data']?['token'] != null);
    }

    return CardTokenResponse(
      token: json['token'] as String? ?? json['data']?['token'] as String? ?? '',
      cardType: json['card_type'] as String? ?? json['data']?['card_type'] as String?,
      last4Digits: json['last4'] as String? ?? json['data']?['last4'] as String?,
      brand: json['brand'] as String? ?? json['data']?['brand'] as String?,
      success: isSuccess,
      message: json['message'] as String? ?? json['data']?['message'] as String?,
    );
  }

  /// Crea una respuesta de error
  factory CardTokenResponse.error(String message) {
    return CardTokenResponse(
      token: '',
      success: false,
      message: message,
    );
  }
}

