import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:dashboardpro/model/netpay/card_token_request.dart';
import 'package:dashboardpro/model/netpay/card_token_response.dart';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

class NetPayWebTokenizer {
  Future<CardTokenResponse> tokenizeCard({
    required CardTokenRequest request,
    required bool useSandbox,
    required String apiKey,
  }) async {
    final netPay = js_util.getProperty<dynamic>(html.window, 'NetPay');
    if (netPay == null) {
      throw Exception(
        'NetPayJS no esta cargado en Web. Agrega el script CDN en web/index.html.',
      );
    }

    js_util.callMethod(netPay, 'setSandboxMode', [useSandbox]);
    js_util.callMethod(netPay, 'setApiKey', [apiKey]);

    final form = js_util.getProperty<dynamic>(netPay, 'form');
    final tokenApi = js_util.getProperty<dynamic>(netPay, 'token');
    if (form == null || tokenApi == null) {
      throw Exception('NetPayJS no expone form/token en esta sesion.');
    }

    final deviceFingerPrint =
        js_util.callMethod<dynamic>(form, 'generateDeviceFingerPrint', []);

    final cardNumber = request.cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    final expMonth = request.expirationMonth.padLeft(2, '0');
    String expYear = request.expirationYear;
    if (expYear.length == 4) {
      expYear = expYear.substring(2);
    } else if (expYear.length == 1) {
      expYear = expYear.padLeft(2, '0');
    }

    final cardInformation = <String, dynamic>{
      'cardNumber': cardNumber,
      'expMonth': expMonth,
      'expYear': expYear,
      'cvv2': request.cvv,
      // Para tarjetas guardadas: vault=true, simpleUse=false.
      'vault': request.saveCard,
      'simpleUse': !request.saveCard,
      'deviceFingerPrint': deviceFingerPrint,
    };

    if (request.street != null && request.street!.isNotEmpty) {
      cardInformation['street'] = request.street;
    }
    if (request.city != null && request.city!.isNotEmpty) {
      cardInformation['city'] = request.city;
    }
    if (request.state != null && request.state!.isNotEmpty) {
      cardInformation['state'] = request.state;
    }
    if (request.postalCode != null && request.postalCode!.isNotEmpty) {
      cardInformation['postalCode'] = request.postalCode;
    }
    if (request.country != null && request.country!.isNotEmpty) {
      cardInformation['country'] = request.country;
    }

    final completer = Completer<CardTokenResponse>();

    final successCallback = allowInterop((dynamic successResponse) {
      try {
        final message = js_util.getProperty<dynamic>(successResponse, 'message');
        dynamic data = message != null
            ? js_util.getProperty<dynamic>(message, 'data')
            : null;

        if (data is String) {
          data = jsonDecode(data);
        } else {
          data = js_util.dartify(data);
        }

        final parsed = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
        final token = parsed['token']?.toString() ?? '';
        if (token.isEmpty) {
          completer.completeError(
            Exception('No se pudo extraer el token de la respuesta de NetPay.'),
          );
          return;
        }

        completer.complete(
          CardTokenResponse(
            token: token,
            cardType: parsed['type']?.toString() ?? parsed['cardType']?.toString(),
            last4Digits: parsed['lastFourDigits']?.toString() ??
                parsed['last4Digits']?.toString() ??
                parsed['last4']?.toString(),
            brand: parsed['brand']?.toString(),
            success: true,
            message: 'Tokenizacion exitosa',
          ),
        );
      } catch (e) {
        completer.completeError(Exception('Error al parsear respuesta de NetPay: $e'));
      }
    });

    final errorCallback = allowInterop((dynamic errorResponse) {
      final errMap = js_util.dartify(errorResponse);
      if (errMap is Map) {
        final map = Map<String, dynamic>.from(errMap);
        final message = map['message']?.toString() ??
            map['error']?.toString() ??
            map['errorMessage']?.toString() ??
            'Error al tokenizar la tarjeta';
        completer.completeError(Exception(message));
        return;
      }
      completer.completeError(Exception('Error al tokenizar la tarjeta'));
    });

    js_util.callMethod(
      tokenApi,
      'create',
      [js_util.jsify(cardInformation), successCallback, errorCallback],
    );

    if (kDebugMode) {
      debugPrint('🌐 NetPay tokenization via JS en Web');
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception(
        'Tiempo de espera agotado al tokenizar en Web.',
      ),
    );
  }
}
