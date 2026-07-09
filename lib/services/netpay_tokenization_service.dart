import 'package:dashboardpro/core/env_config.dart';
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
  final NetPayWebViewService _webViewService;
  
  final bool _useSandbox;

  NetPayTokenizationService({
    bool useSandbox = true, // Por defecto usar sandbox (pruebas)
    String? apiKey,
  })  : _useSandbox = useSandbox,
        _webViewService = NetPayWebViewService(
          useSandbox: useSandbox,
          apiKey: apiKey ?? EnvConfig.netpayPublicApiKey,
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
    }

    try {
      // Validaciones locales antes de enviar
      if (!request.isValid()) {
        throw NetPayTokenizationException(
          message: 'Por favor completa todos los campos requeridos',
        );
      }

      // Validar número de tarjeta (Luhn)
      if (!CardValidator.isValidCardNumber(request.cardNumber)) {
        throw NetPayTokenizationException(
          message: 'El número de tarjeta no es válido.',
        );
      }

      if (kDebugMode) {
        final cardType = CardValidator.detectCardType(request.cardNumber);
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
        if (request.postalCode != null) {
        }
      }

      // Tokenizar usando WebView con NetPayJS
      final tokenResponse = await _webViewService.tokenizeCard(request);

      if (kDebugMode) {
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

