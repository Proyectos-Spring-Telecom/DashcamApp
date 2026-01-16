import 'package:dio/dio.dart';
import 'package:dashboardpro/model/netpay/card_token_request.dart';
import 'package:dashboardpro/model/netpay/card_token_response.dart';
import 'package:dashboardpro/services/netpay_webview_service.dart';
import 'package:dashboardpro/utils/card_validator.dart';
import 'package:flutter/foundation.dart';

/// Excepción personalizada para errores de tokenización
class NetPayTokenizationException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  NetPayTokenizationException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Servicio para tokenización de tarjetas con NetPay
/// 
/// IMPORTANTE DE SEGURIDAD:
/// - Los datos sensibles NO se almacenan ni persisten
/// - Los datos se limpian inmediatamente después de usar
/// - No se imprimen datos sensibles en logs
/// - Usa HTTPS obligatoriamente
/// 
/// Este servicio usa NetPayJS a través de WebView según la documentación oficial de NetPay
class NetPayTokenizationService {
  final Dio _dio; // Mantener Dio por compatibilidad, aunque no se use para tokenización
  final NetPayWebViewService _webViewService;
  
  final bool _useSandbox;

  NetPayTokenizationService({
    Dio? dio,
    bool useSandbox = true, // Por defecto usar sandbox (pruebas)
    String? apiKey,
  })  : _dio = dio ?? Dio(),
        _useSandbox = useSandbox,
        _webViewService = NetPayWebViewService(
          useSandbox: useSandbox,
          apiKey: apiKey,
        ) {
    // El servicio ahora usa WebView con NetPayJS
    // Dio se mantiene por compatibilidad pero no se usa para tokenización
  }

  /// Tokeniza una tarjeta usando NetPayJS a través de WebView
  /// 
  /// Retorna un CardTokenResponse con el token si es exitoso
  /// Lanza NetPayTokenizationException en caso de error
  Future<CardTokenResponse> tokenizeCard(CardTokenRequest request) async {
    if (kDebugMode) {
      debugPrint('🔄 Iniciando tokenización de tarjeta con NetPayJS...');
      debugPrint('🔄 Ambiente: ${_useSandbox ? "SANDBOX" : "PRODUCCIÓN"}');
    }

    try {
      // Validaciones locales antes de enviar
      if (!request.isValid()) {
        if (kDebugMode) {
          debugPrint('❌ Validación local fallida: campos incompletos');
        }
        throw NetPayTokenizationException(
          message: 'Por favor completa todos los campos requeridos',
        );
      }

      // Validar número de tarjeta (Luhn)
      if (!CardValidator.isValidCardNumber(request.cardNumber)) {
        if (kDebugMode) {
          debugPrint('❌ Validación Luhn fallida para número de tarjeta');
        }
        throw NetPayTokenizationException(
          message: 'El número de tarjeta no es válido.',
        );
      }

      if (kDebugMode) {
        final cardType = CardValidator.detectCardType(request.cardNumber);
        debugPrint('✅ Validación Luhn exitosa');
        debugPrint('✅ Tipo de tarjeta detectado: $cardType');
      }

      // Validar fecha de expiración
      if (!CardValidator.isExpirationDateValid(
        request.expirationMonth,
        request.expirationYear,
      )) {
        throw NetPayTokenizationException(
          message: 'La fecha de expiración no es válida o está vencida.',
        );
      }

      // Validar CVV
      final cardType = CardValidator.detectCardType(request.cardNumber);
      if (!CardValidator.isValidCVV(request.cvv, cardType)) {
        throw NetPayTokenizationException(
          message: 'El código CVV no es válido',
        );
      }

      if (kDebugMode) {
        // Mostrar solo campos no sensibles en los logs
        debugPrint('📤 Datos de request:');
        debugPrint('   - Holder: ${request.cardholderName}');
        debugPrint('   - Tiene dirección: ${request.street != null || request.city != null || request.state != null}');
        if (request.postalCode != null) {
          debugPrint('   - Código postal: ${request.postalCode}');
        }
      }

      // Tokenizar usando WebView con NetPayJS
      final tokenResponse = await _webViewService.tokenizeCard(request);

      if (kDebugMode) {
        debugPrint('✅ Tokenización exitosa');
        debugPrint('✅ Últimos 4 dígitos: ${tokenResponse.last4Digits ?? "N/A"}');
        debugPrint('✅ Tipo de tarjeta: ${tokenResponse.cardType ?? "N/A"}');
      }

      return tokenResponse;
    } on NetPayTokenizationException {
      // Re-lanzar excepciones de tokenización
      rethrow;
    } catch (e) {
      // Cualquier otro error
      final errorMessage = e.toString().replaceAll(RegExp(r'Exception: '), '');
      throw NetPayTokenizationException(
        message: errorMessage.isEmpty 
            ? 'Error inesperado. Por favor intenta nuevamente'
            : errorMessage,
        originalError: e,
      );
    }
  }

}

