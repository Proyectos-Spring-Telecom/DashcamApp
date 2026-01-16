/// Utilidades para validar datos de tarjetas de crédito
/// 
/// Estas validaciones son locales y NO reemplazan la validación del servidor
class CardValidator {
  /// Valida el número de tarjeta usando el algoritmo de Luhn
  /// 
  /// Algoritmo:
  /// 1. Duplicar cada segundo dígito empezando desde la derecha
  /// 2. Si el resultado es mayor a 9, sumar los dígitos
  /// 3. Sumar todos los dígitos
  /// 4. Si la suma es divisible por 10, la tarjeta es válida
  static bool isValidCardNumber(String cardNumber) {
    // Remover espacios y caracteres no numéricos
    final cleaned = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verificar que tenga entre 13 y 19 dígitos
    if (cleaned.length < 13 || cleaned.length > 19) {
      return false;
    }

    // Algoritmo de Luhn
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  /// Detecta el tipo de tarjeta basándose en el número
  /// 
  /// Retorna: 'visa', 'mastercard', 'amex', 'discover', o 'unknown'
  static String detectCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.isEmpty) return 'unknown';
    
    // Visa: empieza con 4
    if (cleaned.startsWith('4')) {
      return 'visa';
    }
    
    // MasterCard: empieza con 51-55 o 2221-2720
    if (RegExp(r'^5[1-5]').hasMatch(cleaned) ||
        RegExp(r'^2[2-7]').hasMatch(cleaned)) {
      return 'mastercard';
    }
    
    // American Express: empieza con 34 o 37
    if (cleaned.startsWith('34') || cleaned.startsWith('37')) {
      return 'amex';
    }
    
    // Discover: empieza con 6011, 622126-622925, 644-649, o 65
    if (cleaned.startsWith('6011') ||
        RegExp(r'^622[1-9]').hasMatch(cleaned) ||
        RegExp(r'^64[4-9]').hasMatch(cleaned) ||
        cleaned.startsWith('65')) {
      return 'discover';
    }
    
    return 'unknown';
  }

  /// Valida el CVV según el tipo de tarjeta
  /// 
  /// - Visa/MasterCard/Discover: 3 dígitos
  /// - American Express: 4 dígitos
  static bool isValidCVV(String cvv, String cardType) {
    final cleaned = cvv.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cardType == 'amex') {
      return cleaned.length == 4;
    } else {
      return cleaned.length == 3 || cleaned.length == 4;
    }
  }

  /// Valida que la fecha de expiración no esté vencida
  /// 
  /// month: MM (01-12)
  /// year: YY o YYYY
  static bool isExpirationDateValid(String month, String year) {
    try {
      final monthInt = int.parse(month);
      if (monthInt < 1 || monthInt > 12) return false;

      // Convertir año a 4 dígitos si es necesario
      int yearInt;
      if (year.length == 2) {
        yearInt = 2000 + int.parse(year);
      } else if (year.length == 4) {
        yearInt = int.parse(year);
      } else {
        return false;
      }

      // Obtener fecha actual
      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      // Crear fecha de expiración (último día del mes)
      final expirationDate = DateTime(yearInt, monthInt + 1, 0);

      // Verificar que no esté vencida
      return expirationDate.isAfter(DateTime(currentYear, currentMonth, 0));
    } catch (e) {
      return false;
    }
  }

  /// Valida formato de mes (MM)
  static bool isValidMonth(String month) {
    try {
      final monthInt = int.parse(month);
      return monthInt >= 1 && monthInt <= 12;
    } catch (e) {
      return false;
    }
  }

  /// Valida formato de año (YY o YYYY)
  static bool isValidYear(String year) {
    return year.length == 2 || year.length == 4;
  }

  /// Formatea el número de tarjeta mostrando solo los últimos 4 dígitos
  /// 
  /// Ejemplo: "**** **** **** 1234"
  static String maskCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 4) return cardNumber;
    
    final last4 = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $last4';
  }
}

