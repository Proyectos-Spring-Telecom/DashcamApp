/// Modelo para el request de recarga de monedero
/// Endpoint: POST /transacciones/recarga
class RecargaRequest {
  final int idTipoTransaccion;
  final double monto;
  final double? latitudInicial;
  final double? longitudInicial;
  final String numeroSerieMonedero;
  final String? numeroSerieValidador;
  final int idMetodoPago;
  final String? tokenCardNetPay;
  final String? transactionTokenIdNetPay;
  final String? referenceIdNetPay;
  final String? sessionId;
  final String? deviceFingerPrint;
  final int? idDireccion;
  final Map<String, dynamic>? deviceInformation;

  RecargaRequest({
    required this.idTipoTransaccion,
    required this.monto,
    this.latitudInicial,
    this.longitudInicial,
    required this.numeroSerieMonedero,
    this.numeroSerieValidador,
    required this.idMetodoPago,
    this.tokenCardNetPay,
    this.transactionTokenIdNetPay,
    this.referenceIdNetPay,
    this.sessionId,
    this.deviceFingerPrint,
    this.idDireccion,
    this.deviceInformation,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'idTipoTransaccion': idTipoTransaccion,
      'monto': monto,
      'numeroSerieMonedero': numeroSerieMonedero,
      'idMetodoPago': idMetodoPago,
    };

    if (latitudInicial != null) {
      json['latitudInicial'] = latitudInicial;
    }
    if (longitudInicial != null) {
      json['longitudInicial'] = longitudInicial;
    }
    // numeroSerieValidador se envía como null explícitamente según requerimientos
    json['numeroSerieValidador'] = numeroSerieValidador;
    
    // Campos obligatorios para tarjeta (idMetodoPago 3 o 4)
    if (idMetodoPago == 3 || idMetodoPago == 4) {
      // Todos estos campos son obligatorios cuando es tarjeta
      if (tokenCardNetPay == null || tokenCardNetPay!.isEmpty) {
        throw Exception('tokenCardNetPay es obligatorio cuando el método de pago es Tarjeta');
      }
      if (transactionTokenIdNetPay == null || transactionTokenIdNetPay!.isEmpty) {
        throw Exception('transactionTokenIdNetPay es obligatorio cuando el método de pago es Tarjeta');
      }
      if (referenceIdNetPay == null || referenceIdNetPay!.isEmpty) {
        throw Exception('referenceIdNetPay es obligatorio cuando el método de pago es Tarjeta');
      }
      if (sessionId == null || sessionId!.isEmpty) {
        throw Exception('sessionId es obligatorio cuando el método de pago es Tarjeta');
      }
      if (deviceFingerPrint == null || deviceFingerPrint!.isEmpty) {
        throw Exception('deviceFingerPrint es obligatorio cuando el método de pago es Tarjeta');
      }
      if (idDireccion == null) {
        throw Exception('idDireccion es obligatorio cuando el método de pago es Tarjeta');
      }
      
      // Incluir todos los campos obligatorios para tarjeta
      json['tokenCardNetPay'] = tokenCardNetPay;
      json['transactionTokenIdNetPay'] = transactionTokenIdNetPay;
      json['referenceIdNetPay'] = referenceIdNetPay;
      json['sessionId'] = sessionId;
      json['deviceFingerPrint'] = deviceFingerPrint;
      json['idDireccion'] = idDireccion;
    } else {
      // Para efectivo, estos campos no se envían
      if (tokenCardNetPay != null && tokenCardNetPay!.isNotEmpty) {
        json['tokenCardNetPay'] = tokenCardNetPay;
      }
      if (transactionTokenIdNetPay != null && transactionTokenIdNetPay!.isNotEmpty) {
        json['transactionTokenIdNetPay'] = transactionTokenIdNetPay;
      }
      if (referenceIdNetPay != null && referenceIdNetPay!.isNotEmpty) {
        json['referenceIdNetPay'] = referenceIdNetPay;
      }
      if (sessionId != null && sessionId!.isNotEmpty) {
        json['sessionId'] = sessionId;
      }
      if (deviceFingerPrint != null && deviceFingerPrint!.isNotEmpty) {
        json['deviceFingerPrint'] = deviceFingerPrint;
      }
      if (idDireccion != null) {
        json['idDireccion'] = idDireccion;
      }
    }
    
    // deviceInformation siempre se incluye si está presente
    if (deviceInformation != null && deviceInformation!.isNotEmpty) {
      json['deviceInformation'] = deviceInformation;
    }

    return json;
  }
}

