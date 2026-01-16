import 'package:dashboardpro/services/netpay_tokenization_service.dart';
import 'package:dashboardpro/model/netpay/card_token_request.dart';
import 'package:dashboardpro/model/netpay/card_token_response.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Estados del proceso de tokenización
enum TokenizationStatus {
  initial,
  loading,
  success,
  error,
}

/// BLoC para manejar la tokenización de tarjetas con NetPay
/// 
/// IMPORTANTE: Este BLoC NO almacena datos sensibles de la tarjeta
class NetPayTokenizationBloc {
  final NetPayTokenizationService _tokenizationService;

  // Streams para el estado
  final _statusController = StreamController<TokenizationStatus>.broadcast();
  final _tokenController = StreamController<CardTokenResponse?>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  // Estado actual
  TokenizationStatus _status = TokenizationStatus.initial;
  CardTokenResponse? _tokenResponse;
  String? _errorMessage;

  // Getters para streams
  Stream<TokenizationStatus> get statusStream => _statusController.stream;
  Stream<CardTokenResponse?> get tokenStream => _tokenController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Getters para estado actual
  TokenizationStatus get status => _status;
  CardTokenResponse? get tokenResponse => _tokenResponse;
  String? get errorMessage => _errorMessage;

  NetPayTokenizationBloc({
    NetPayTokenizationService? tokenizationService,
    bool useSandbox = true,
    String? apiKey,
  }) : _tokenizationService = tokenizationService ??
            NetPayTokenizationService(
              useSandbox: useSandbox,
              apiKey: apiKey,
            ) {
    // Emitir estado inicial
    _updateStatus(TokenizationStatus.initial);
  }

  /// Tokeniza una tarjeta
  /// 
  /// IMPORTANTE: Los datos sensibles se limpian después de usar
  Future<void> tokenizeCard(CardTokenRequest request) async {
    try {
      // Actualizar estado a loading
      _updateStatus(TokenizationStatus.loading);
      _clearError();

      // Tokenizar la tarjeta
      final response = await _tokenizationService.tokenizeCard(request);

      // Guardar solo el token (no datos sensibles)
      _tokenResponse = response;

      if (response.success && response.token.isNotEmpty) {
        _updateStatus(TokenizationStatus.success);
        _tokenController.add(response);
      } else {
        _updateError(response.message ?? 'Error al tokenizar la tarjeta');
        _updateStatus(TokenizationStatus.error);
      }
    } on NetPayTokenizationException catch (e) {
      // Manejar excepciones de tokenización
      _updateError(e.message);
      _updateStatus(TokenizationStatus.error);
    } catch (e) {
      // Manejar cualquier otro error
      _updateError('Error inesperado. Por favor intenta nuevamente');
      _updateStatus(TokenizationStatus.error);
      if (kDebugMode) {
        debugPrint('Error inesperado en tokenización: $e');
      }
    }
  }

  /// Limpia el estado y resetea el BLoC
  void reset() {
    _status = TokenizationStatus.initial;
    _tokenResponse = null;
    _errorMessage = null;
    _statusController.add(_status);
    _tokenController.add(null);
    _errorController.add(null);
  }

  /// Actualiza el estado
  void _updateStatus(TokenizationStatus newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }

  /// Actualiza el mensaje de error
  void _updateError(String message) {
    _errorMessage = message;
    _errorController.add(message);
  }

  /// Limpia el error
  void _clearError() {
    _errorMessage = null;
    _errorController.add(null);
  }

  /// Libera los recursos del BLoC
  void dispose() {
    _statusController.close();
    _tokenController.close();
    _errorController.close();
  }
}

/// Instancia global del BLoC (siguiendo el patrón del proyecto)
final netPayTokenizationBloc = NetPayTokenizationBloc();

