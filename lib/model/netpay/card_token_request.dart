/// Modelo para la solicitud de tokenización de tarjeta a NetPay
/// 
/// IMPORTANTE: Este modelo NO almacena datos sensibles después del uso.
/// Los datos deben limpiarse inmediatamente después de enviar la petición.
class CardTokenRequest {
  /// Número de tarjeta (sin espacios)
  final String cardNumber;
  
  /// Nombre del titular de la tarjeta
  final String cardholderName;
  
  /// Mes de expiración (2 dígitos: 01-12)
  final String expirationMonth;
  
  /// Año de expiración (2 dígitos: YY)
  final String expirationYear;
  
  /// Código de seguridad (CVV)
  final String cvv;

  // Datos de dirección (opcionales pero recomendados)
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  CardTokenRequest({
    required this.cardNumber,
    required this.cardholderName,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvv,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  /// Convierte el modelo a JSON para enviar a NetPay
  /// 
  /// IMPORTANTE: No registrar ni imprimir este JSON completo por seguridad
  Map<String, dynamic> toJson() {
    // Asegurar que el año tenga 2 dígitos
    String year = expirationYear;
    if (year.length == 4) {
      year = year.substring(2);
    }

    final json = <String, dynamic>{
      'card_number': cardNumber.replaceAll(RegExp(r'[^\d]'), ''), // Limpiar espacios
      'holder_name': cardholderName.trim(),
      'expiration_month': expirationMonth.padLeft(2, '0'),
      'expiration_year': year.padLeft(2, '0'),
      'cvv2': cvv,
    };

    // Agregar datos de dirección si están disponibles
    if (street != null && street!.isNotEmpty) {
      json['street'] = street;
    }
    if (city != null && city!.isNotEmpty) {
      json['city'] = city;
    }
    if (state != null && state!.isNotEmpty) {
      json['state'] = state;
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      json['postal_code'] = postalCode;
    }
    json['country'] = country ?? 'MX'; // Por defecto México

    return json;
  }

  /// Valida que todos los campos requeridos estén presentes
  bool isValid() {
    return cardNumber.isNotEmpty &&
        cardholderName.isNotEmpty &&
        expirationMonth.isNotEmpty &&
        expirationYear.isNotEmpty &&
        cvv.isNotEmpty;
  }
}

