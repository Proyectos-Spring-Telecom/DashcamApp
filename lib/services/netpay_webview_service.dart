import 'dart:async';
import 'dart:convert';
import 'package:dashboardpro/core/env_config.dart';
import 'package:dashboardpro/model/netpay/card_token_request.dart';
import 'package:dashboardpro/model/netpay/card_token_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Servicio para tokenización de tarjetas usando NetPayJS en WebView
/// 
/// IMPORTANTE DE SEGURIDAD:
/// - Los datos sensibles NO se almacenan ni persisten
/// - Los datos se limpian inmediatamente después de usar
/// - No se imprimen datos sensibles en logs
/// - Usa HTTPS obligatoriamente
/// - La API key de NetPay viene de .env (EnvConfig.netpayPublicApiKey)
class NetPayWebViewService {
  final bool _useSandbox;
  final String _apiKey;

  NetPayWebViewService({
    bool useSandbox = true,
    String? apiKey,
  })  : _useSandbox = useSandbox,
        _apiKey = apiKey?.trim().isNotEmpty == true
            ? apiKey!
            : EnvConfig.netpayPublicApiKey;

  WebViewController? _webViewController;
  final _completerController = <String, Completer<CardTokenResponse>>{};
  String? _currentRequestId;

  /// Inicializa el WebView y carga el HTML de NetPay
  Future<void> initializeWebView() async {
    if (_webViewController != null) {
      // Ya está inicializado
      return;
    }

    // Cargar el HTML desde assets
    final htmlContent = await rootBundle.loadString('assets/html/netpay_tokenization.html');

    // Crear el controlador del WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (kDebugMode) {
              debugPrint('📄 Página cargada en WebView');
            }
            // Configurar NetPay después de que la página se cargue
            _configureNetPay();
          },
        ),
      )
      ..addJavaScriptChannel(
        'NetPayChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleMessageFromWebView(message.message);
        },
      )
      ..loadRequest(
        Uri.dataFromString(
          htmlContent,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );

    if (kDebugMode) {
      debugPrint('🔵 WebView inicializado para NetPay');
    }
  }

  /// Configura NetPay con la API key y modo sandbox
  Future<void> _configureNetPay() async {
    if (_webViewController == null) {
      await initializeWebView();
    }

    final script = '''
      if (typeof handleMessageFromFlutter === 'function') {
        handleMessageFromFlutter(JSON.stringify({
          action: 'configure',
          apiKey: '$_apiKey',
          useSandbox: $_useSandbox
        }));
      } else {
        console.error('handleMessageFromFlutter no está disponible');
      }
    ''';

    await _webViewController!.runJavaScript(script);

    if (kDebugMode) {
      debugPrint('⚙️ NetPay configurado con API key y sandbox: $_useSandbox');
    }
  }

  /// Tokeniza una tarjeta usando NetPayJS
  Future<CardTokenResponse> tokenizeCard(CardTokenRequest request) async {
    // Inicializar WebView si no está inicializado
    if (_webViewController == null) {
      await initializeWebView();
      // Esperar un momento para que NetPayJS se cargue
      await Future.delayed(const Duration(milliseconds: 500));
      await _configureNetPay();
      // Esperar un momento adicional para la configuración
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Generar un ID único para esta solicitud
    _currentRequestId = DateTime.now().millisecondsSinceEpoch.toString();
    final completer = Completer<CardTokenResponse>();
    _completerController[_currentRequestId!] = completer;

    try {
      // Preparar datos para enviar al WebView
      // Limpiar número de tarjeta (eliminar espacios y caracteres no numéricos)
      final cleanCardNumber = request.cardNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // Asegurar que el año tenga 2 dígitos
      String expirationYear = request.expirationYear;
      if (expirationYear.length == 4) {
        expirationYear = expirationYear.substring(2);
      } else if (expirationYear.length == 1) {
        expirationYear = expirationYear.padLeft(2, '0');
      }
      
      final tokenData = {
        'action': 'tokenize',
        'requestId': _currentRequestId,
        'cardNumber': cleanCardNumber,
        'cardholderName': request.cardholderName,
        'expirationMonth': request.expirationMonth.padLeft(2, '0'),
        'expirationYear': expirationYear,
        'cvv': request.cvv,
        'saveCard': false, // Por defecto no guardar, se puede pasar desde el request en el futuro
      };

      // Agregar dirección si está disponible
      if (request.street != null && request.street!.isNotEmpty) {
        tokenData['street'] = request.street;
      }
      if (request.city != null && request.city!.isNotEmpty) {
        tokenData['city'] = request.city;
      }
      if (request.state != null && request.state!.isNotEmpty) {
        tokenData['state'] = request.state;
      }
      if (request.postalCode != null && request.postalCode!.isNotEmpty) {
        tokenData['postalCode'] = request.postalCode;
      }
      if (request.country != null && request.country!.isNotEmpty) {
        tokenData['country'] = request.country;
      }

      // Enviar datos al WebView
      final script = '''
        if (typeof handleMessageFromFlutter === 'function') {
          handleMessageFromFlutter(${jsonEncode(tokenData)});
        } else {
          console.error('handleMessageFromFlutter no está disponible');
        }
      ''';

      await _webViewController!.runJavaScript(script);

      if (kDebugMode) {
        debugPrint('📤 Datos enviados al WebView para tokenización');
        debugPrint('📤 Request ID: $_currentRequestId');
      }

      // Esperar la respuesta (con timeout)
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _completerController.remove(_currentRequestId);
          if (kDebugMode) {
            debugPrint('⏱️ Timeout: La tokenización tardó más de 30 segundos');
          }
          throw Exception('Tiempo de espera agotado. Por favor, verifica tu conexión a internet e intenta nuevamente.');
        },
      );
    } catch (e) {
      _completerController.remove(_currentRequestId);
      if (kDebugMode) {
        debugPrint('❌ Error en tokenizeCard: $e');
      }
      rethrow;
    }
  }

  /// Maneja mensajes desde el WebView
  void _handleMessageFromWebView(String messageJson) {
    try {
      final message = jsonDecode(messageJson) as Map<String, dynamic>;
      final type = message['type'] as String?;
      final requestId = message['requestId'] as String?;

      if (kDebugMode) {
        debugPrint('📥 Mensaje recibido del WebView: $type');
      }

      switch (type) {
        case 'ready':
          if (kDebugMode) {
            debugPrint('✅ NetPayJS está listo');
          }
          break;

        case 'configured':
          if (kDebugMode) {
            debugPrint('✅ NetPay configurado correctamente');
          }
          break;

        case 'success':
          if (requestId != null && _completerController.containsKey(requestId)) {
            final completer = _completerController.remove(requestId)!;
            
            final token = message['token'] as String? ?? '';
            final cardType = message['cardType'] as String?;
            final last4Digits = message['last4Digits'] as String?;
            final brand = message['brand'] as String?;

            if (token.isEmpty) {
              if (kDebugMode) {
                debugPrint('❌ Token vacío recibido de NetPay');
              }
              completer.completeError('Token vacío recibido de NetPay');
              return;
            }

            final response = CardTokenResponse(
              token: token,
              cardType: cardType,
              last4Digits: last4Digits,
              brand: brand,
              success: true,
              message: 'Tokenización exitosa',
            );

            completer.complete(response);

            if (kDebugMode) {
              debugPrint('✅ Tokenización exitosa');
            }
          }
          break;

        case 'error':
          if (requestId != null && _completerController.containsKey(requestId)) {
            final completer = _completerController.remove(requestId)!;
            final errorMessageRaw = message['message'] as String?;
            final errorCode = message['errorCode'] as String?;
            
            // Mejorar el mensaje de error según el código o contenido
            String errorMessage = 'Se ha producido un error al generar el token de la tarjeta';
            
            if (errorMessageRaw != null && errorMessageRaw.isNotEmpty) {
              errorMessage = errorMessageRaw;
              
              // Mejorar mensajes específicos de NetPay
              if (errorMessage.contains('device fingerprint') || 
                  errorMessage.contains('DeviceFingerPrint') ||
                  errorCode == 'DEVICE_FINGERPRINT_ERROR') {
                errorMessage = 'Error al generar la huella digital del dispositivo. Por favor, intenta nuevamente.';
              } else if (errorMessage.contains('invalid') || 
                         errorMessage.contains('inválid') ||
                         errorMessage.contains('card number') ||
                         errorCode == 'INVALID_CARD') {
                errorMessage = 'Los datos de la tarjeta no son válidos. Por favor, verifica el número de tarjeta, fecha de expiración y CVV.';
              } else if (errorMessage.contains('expired') || 
                         errorMessage.contains('vencid') ||
                         errorCode == 'CARD_EXPIRED') {
                errorMessage = 'La tarjeta está vencida. Por favor, verifica la fecha de expiración.';
              } else if (errorMessage.contains('network') || 
                         errorMessage.contains('conexión') ||
                         errorMessage.contains('timeout') ||
                         errorCode == 'NETWORK_ERROR') {
                errorMessage = 'Error de conexión. Por favor, verifica tu conexión a internet e intenta nuevamente.';
              } else if (errorMessage.contains('not configured') || 
                         errorMessage.contains('no está configurado')) {
                errorMessage = 'El servicio de pagos no está configurado correctamente. Por favor, contacta al soporte.';
              } else if (errorMessage.contains('api key') || 
                         errorCode == 'INVALID_API_KEY') {
                errorMessage = 'Error de configuración del servicio de pagos. Por favor, contacta al soporte.';
              }
            }
            
            completer.completeError(errorMessage);

            if (kDebugMode) {
              debugPrint('❌ Error de tokenización: $errorMessage');
              debugPrint('❌ Código de error: $errorCode');
              debugPrint('❌ Mensaje original: $errorMessageRaw');
            }
          }
          break;

        default:
          if (kDebugMode) {
            debugPrint('⚠️ Tipo de mensaje desconocido: $type');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al procesar mensaje del WebView: $e');
      }
      // Intentar completar con error si hay un requestId
      final requestId = _currentRequestId;
      if (requestId != null && _completerController.containsKey(requestId)) {
        final completer = _completerController.remove(requestId)!;
        final errorMsg = e.toString().contains('Exception: ') 
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Se ha producido un error al generar el token de la tarjeta';
        completer.completeError(errorMsg);
      }
    }
  }

  /// Libera los recursos del servicio
  void dispose() {
    _completerController.clear();
    _webViewController = null;
  }
}

