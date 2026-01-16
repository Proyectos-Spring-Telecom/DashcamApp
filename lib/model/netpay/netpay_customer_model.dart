class NetPayCustomerModel {
  final String id;
  final String name;
  final String email;
  final List<PaymentSourceModel> paymentSources;
  final List<DatoTarjetaModel> datosTarjeta;

  NetPayCustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.paymentSources,
    required this.datosTarjeta,
  });

  factory NetPayCustomerModel.fromJson(Map<String, dynamic> json) {
    return NetPayCustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      paymentSources: json['paymentSources'] != null
          ? (json['paymentSources'] as List<dynamic>)
              .map((item) => PaymentSourceModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      datosTarjeta: json['datosTarjeta'] != null
          ? (json['datosTarjeta'] as List<dynamic>)
              .map((item) => DatoTarjetaModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'paymentSources': paymentSources.map((item) => item.toJson()).toList(),
      'datosTarjeta': datosTarjeta.map((item) => item.toJson()).toList(),
    };
  }
}

class DatoTarjetaModel {
  final String tokenCard;
  final int? idDireccion;

  DatoTarjetaModel({
    required this.tokenCard,
    this.idDireccion,
  });

  factory DatoTarjetaModel.fromJson(Map<String, dynamic> json) {
    return DatoTarjetaModel(
      tokenCard: json['tokenCard']?.toString() ?? '',
      idDireccion: json['idDireccion'] != null
          ? (json['idDireccion'] is int
              ? json['idDireccion'] as int
              : int.tryParse(json['idDireccion'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenCard': tokenCard,
      if (idDireccion != null) 'idDireccion': idDireccion,
    };
  }
}

class PaymentSourceModel {
  final bool cardDefault;
  final CardModel card;
  final String source;
  final String type;
  final String? deviceFingerPrint;
  final int? idDireccion;

  PaymentSourceModel({
    required this.cardDefault,
    required this.card,
    required this.source,
    required this.type,
    this.deviceFingerPrint,
    this.idDireccion,
  });

  factory PaymentSourceModel.fromJson(Map<String, dynamic> json) {
    // El deviceFingerPrint puede estar en el nivel de paymentSource o dentro de card
    String? deviceFingerPrint;
    
    // Primero intentar obtenerlo del nivel de paymentSource
    if (json.containsKey('deviceFingerPrint')) {
      deviceFingerPrint = json['deviceFingerPrint']?.toString();
    }
    // Si no está ahí, intentar obtenerlo del objeto card
    else if (json.containsKey('card') && json['card'] is Map<String, dynamic>) {
      final cardData = json['card'] as Map<String, dynamic>;
      if (cardData.containsKey('deviceFingerPrint')) {
        deviceFingerPrint = cardData['deviceFingerPrint']?.toString();
      }
    }
    
    // El idDireccion puede estar en el nivel de paymentSource o dentro de card
    int? idDireccion;
    
    // Primero intentar obtenerlo del nivel de paymentSource
    if (json.containsKey('idDireccion')) {
      idDireccion = json['idDireccion'] is int 
          ? json['idDireccion'] as int 
          : int.tryParse(json['idDireccion'].toString());
    }
    // Si no está ahí, intentar obtenerlo del objeto card
    else if (json.containsKey('card') && json['card'] is Map<String, dynamic>) {
      final cardData = json['card'] as Map<String, dynamic>;
      if (cardData.containsKey('idDireccion')) {
        idDireccion = cardData['idDireccion'] is int 
            ? cardData['idDireccion'] as int 
            : int.tryParse(cardData['idDireccion'].toString());
      }
    }
    
    return PaymentSourceModel(
      cardDefault: json['cardDefault'] as bool? ?? false,
      card: CardModel.fromJson(json['card'] as Map<String, dynamic>),
      source: json['source']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      deviceFingerPrint: deviceFingerPrint,
      idDireccion: idDireccion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardDefault': cardDefault,
      'card': card.toJson(),
      'source': source,
      'type': type,
      if (deviceFingerPrint != null) 'deviceFingerPrint': deviceFingerPrint,
      if (idDireccion != null) 'idDireccion': idDireccion,
    };
  }
}

class CardModel {
  final String token;
  final String expYear;
  final String expMonth;
  final String lastFourDigits;
  final String brand;
  final String? bank;
  final String type;
  final String? country;
  final int? idDireccion;

  CardModel({
    required this.token,
    required this.expYear,
    required this.expMonth,
    required this.lastFourDigits,
    required this.brand,
    this.bank,
    required this.type,
    this.country,
    this.idDireccion,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      token: json['token']?.toString() ?? '',
      expYear: json['expYear']?.toString() ?? '',
      expMonth: json['expMonth']?.toString() ?? '',
      lastFourDigits: json['lastFourDigits']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      bank: json['bank']?.toString(),
      type: json['type']?.toString() ?? '',
      country: json['country']?.toString(),
      idDireccion: json['idDireccion'] != null 
          ? (json['idDireccion'] is int 
              ? json['idDireccion'] as int 
              : int.tryParse(json['idDireccion'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expYear': expYear,
      'expMonth': expMonth,
      'lastFourDigits': lastFourDigits,
      'brand': brand,
      'bank': bank,
      'type': type,
      'country': country,
      if (idDireccion != null) 'idDireccion': idDireccion,
    };
  }

  /// Obtiene el nombre de la marca formateado
  String get brandFormatted {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
      case 'american express':
        return 'American Express';
      case 'discover':
        return 'Discover';
      default:
        return brand.isNotEmpty ? brand.toUpperCase() : 'Tarjeta';
    }
  }

  /// Obtiene el tipo de tarjeta formateado
  String get typeFormatted {
    switch (type.toLowerCase()) {
      case 'credit':
        return 'Crédito';
      case 'debit':
        return 'Débito';
      default:
        return type.isNotEmpty ? type : 'Tarjeta';
    }
  }

  /// Obtiene la fecha de expiración formateada (MM / YY)
  String get expirationFormatted {
    if (expMonth.isEmpty || expYear.isEmpty) return '-- / --';
    
    // Asegurar que expMonth tenga 2 dígitos
    final month = expMonth.length == 1 ? '0$expMonth' : expMonth;
    
    // Si expYear tiene 4 dígitos, tomar solo los últimos 2
    final year = expYear.length == 4 ? expYear.substring(2) : expYear;
    
    return '$month / $year';
  }
}

