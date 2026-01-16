import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import: usa la versión web si es web, sino usa el stub
import 'nfc_user_agent_stub.dart'
    if (dart.library.html) 'nfc_user_agent_web.dart' as user_agent_helper;

/// Servicio para leer tarjetas NFC usando flutter_nfc_kit
/// Solo lectura local, no almacena ni envía información
class NfcService {
  bool _isSessionActive = false;
  int _errorCount = 0;
  static const int _maxRetries = 2;
  
  /// Detecta si estamos en iOS web (Safari o PWA)
  bool _isIosWeb() {
    if (!kIsWeb) return false;
    // Intentar detectar iOS desde el User-Agent usando dart:html
    try {
      // Nota: Esta verificación requiere dart:html que solo está disponible en web
      return _detectIosFromUserAgent();
    } catch (e) {
      // Si no podemos detectar, asumir que podría ser iOS
      return false;
    }
  }
  
  /// Detecta iOS desde User-Agent (solo disponible en web)
  bool _detectIosFromUserAgent() {
    if (!kIsWeb) return false;
    try {
      // Usar el helper que tiene conditional imports
      final userAgent = user_agent_helper.getUserAgent()?.toLowerCase();
      
      if (userAgent == null || userAgent.isEmpty) return false;
      
      // Detectar iOS desde User-Agent
      final isIos = userAgent.contains('iphone') || 
                    userAgent.contains('ipad') || 
                    userAgent.contains('ipod') ||
                    (userAgent.contains('macintosh') && userAgent.contains('mobile'));
      
      if (kDebugMode && isIos) {
        debugPrint('🔍 iOS detectado desde User-Agent: $userAgent');
      }
      
      return isIos;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error al detectar iOS desde User-Agent: $e');
      }
      return false;
    }
  }
  
  /// Verifica si NFC está disponible en el dispositivo
  /// Retorna true si NFC está disponible (no verifica si hay tags)
  Future<bool> isAvailable() async {
    try {
      // En web, especialmente iOS, NFC no está disponible
      if (kIsWeb) {
        // Verificar si es iOS web
        if (_isIosWeb()) {
          if (kDebugMode) {
            debugPrint('⚠️ NFC no está disponible en iOS Safari/PWA');
            debugPrint('⚠️ iOS Safari no soporta Web NFC API');
          }
          return false;
        }
        
        // En Android Chrome, podría estar disponible vía WebUSB
        // pero requiere hardware específico y configuración
        if (kDebugMode) {
          debugPrint('⚠️ NFC en web tiene soporte limitado');
          debugPrint('⚠️ Solo funciona en Android Chrome con hardware compatible');
        }
        // Intentar verificar disponibilidad real
      }
      
      // Para plataformas nativas (Android/iOS), asumir disponible
      // El error se manejará en readCard() si realmente no está disponible
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error al verificar disponibilidad NFC: $e');
      }
      return false;
    }
  }

  /// Inicia la lectura de una tarjeta NFC
  /// Retorna el número de tarjeta si está disponible
  /// Lanza excepciones si hay errores o el usuario cancela
  Future<String?> readCard({int retryCount = 0}) async {
    // Verificar disponibilidad antes de intentar leer
    final available = await isAvailable();
    if (!available) {
      if (kIsWeb && _isIosWeb()) {
        throw NfcException('NFC no está disponible en iOS Safari. iOS no soporta Web NFC API. Por favor, usa la aplicación nativa o un dispositivo Android.');
      } else if (kIsWeb) {
        throw NfcException('NFC en web tiene soporte limitado. Solo funciona en Android Chrome con hardware compatible. Por favor, usa la aplicación nativa para una mejor experiencia.');
      }
      throw NfcException('NFC no está disponible en este dispositivo');
    }
    
    // Si hay una sesión activa, esperar y cerrarla primero
    if (_isSessionActive) {
      if (kDebugMode) {
        debugPrint('⚠️ Hay una sesión activa, cerrando...');
      }
      try {
        await FlutterNfcKit.finish();
        // Esperar un momento para que el sistema libere los recursos
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (_) {
        // Ignorar errores
      }
      _isSessionActive = false;
    }

    String? cardNumber;

    try {
      if (kDebugMode) {
        debugPrint('');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('📱 SESIÓN NFC ACTIVADA');
        debugPrint('📱 ✅ AHORA SÍ puedes acercar el tag');
        debugPrint('📱 Esperando tarjeta NFC (máximo 30 segundos)...');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('');
      }

      // IMPORTANTE: poll() inicia una sesión NFC activa que toma el control
      // Esto evita que Android muestre el diálogo "No hay apps compatibles"
      // El usuario DEBE acercar el tag DESPUÉS de que se llame a poll()
      _isSessionActive = true;
      
      // Si ha habido errores previos, esperar un poco más antes de intentar
      if (_errorCount > 0) {
        await Future.delayed(Duration(milliseconds: 500 * _errorCount));
      }
      
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 30),
      );
      
      // Si llegamos aquí, la lectura fue exitosa, resetear contador de errores
      _errorCount = 0;

      try {
        if (kDebugMode) {
          debugPrint('📱 Tag NFC detectado');
          debugPrint('📱 Tipo: ${tag.type}');
          debugPrint('📱 Estándar: ${tag.standard}');
          debugPrint('📱 ID: ${tag.id}');
        }

        // Intentar leer el número de tarjeta
        cardNumber = _extractCardNumber(tag);

        final hasCardNumber = cardNumber?.isNotEmpty ?? false;
        if (hasCardNumber) {
          if (kDebugMode) {
            debugPrint('');
            debugPrint('═══════════════════════════════════════════');
            debugPrint('✅ TARJETA LEÍDA EXITOSAMENTE');
            debugPrint('✅ Número de tarjeta NFC: $cardNumber');
            debugPrint('═══════════════════════════════════════════');
            debugPrint('');
          }
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ No se pudo extraer el número de tarjeta del tag');
            debugPrint('📱 Tipo de tag: ${tag.type}');
            debugPrint('📱 Estándar: ${tag.standard}');
          }
        }

        // Nota: La lectura de NDEF requiere configuración adicional
        // Por ahora solo leemos el ID de la tarjeta que es suficiente para identificar la tarjeta

        // Finalizar sesión después de leer
        _isSessionActive = false;
        await FlutterNfcKit.finish();
        // Pequeño delay para asegurar que el sistema libere los recursos
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error al procesar tag NFC: $e');
        }
        _isSessionActive = false;
        try {
          await FlutterNfcKit.finish();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {
          // Ignorar errores
        }
        rethrow;
      }
    } on NfcException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error NFC: ${e.message}');
      }
      _isSessionActive = false;
      try {
        await FlutterNfcKit.finish();
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {
        // Ignorar errores al finalizar
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error inesperado al leer NFC: $e');
      }
      _isSessionActive = false;
      try {
        await FlutterNfcKit.finish();
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {
        // Ignorar errores al finalizar
      }
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
        throw NfcException('Tiempo de espera agotado. No se detectó ninguna tarjeta.');
      } else if (errorStr.contains('user cancel') || errorStr.contains('cancelled')) {
        throw NfcException('Lectura cancelada por el usuario');
      } else if (errorStr.contains('nfc not available') || 
                 errorStr.contains('nfc not supported')) {
        throw NfcException('NFC no está disponible en este dispositivo');
      } else {
        // Si es MissingPluginException, el plugin no está registrado
        // Esto puede ocurrir si la app no se recompiló correctamente o después de múltiples usos
        if (errorStr.contains('missingplugin') || errorStr.contains('no implementation')) {
          if (retryCount < _maxRetries) {
            if (kDebugMode) {
              debugPrint('⚠️ MissingPluginException detectado, reintentando... (intento ${retryCount + 1}/$_maxRetries)');
            }
            // Esperar antes de reintentar
            await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
            // Reintentar la lectura
            return readCard(retryCount: retryCount + 1);
          } else {
            _errorCount = 0;
            throw NfcException('El plugin NFC no está disponible después de varios intentos. Por favor, detén la app completamente y recompila con: flutter run');
          }
        }
        throw NfcException('Error al leer tarjeta NFC: $e');
      }
    } finally {
      // Asegurarse de cerrar la sesión en cualquier caso
      if (_isSessionActive) {
        try {
          await FlutterNfcKit.finish();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {
          // Ignorar errores al finalizar
        }
        _isSessionActive = false;
      }
    }

    return cardNumber;
  }

  /// Extrae el número de tarjeta desde el tag NFC
  /// En flutter_nfc_kit, tag.id es un String hexadecimal
  String? _extractCardNumber(NFCTag tag) {
    try {
      // tag.id es un String hexadecimal
      final idString = tag.id;
      
      if (idString.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ El tag no tiene ID');
        }
        return null;
      }

      // El ID ya está en formato hexadecimal, lo retornamos directamente
      if (kDebugMode) {
        debugPrint('📱 Identifier extraído (hex): $idString');
        debugPrint('📱 Longitud: ${idString.length} caracteres');
      }

      return idString;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al extraer número de tarjeta: $e');
      }
      return null;
    }
  }

  /// Cancela la sesión NFC activa
  Future<void> stopSession() async {
    if (!_isSessionActive) {
      return;
    }
    try {
      await FlutterNfcKit.finish();
      await Future.delayed(const Duration(milliseconds: 200));
      _isSessionActive = false;
      if (kDebugMode) {
        debugPrint('🛑 Sesión NFC cancelada');
      }
    } catch (e) {
      _isSessionActive = false;
      if (kDebugMode) {
        debugPrint('⚠️ Error al cancelar sesión NFC: $e');
      }
    }
  }
}

/// Excepción personalizada para errores NFC
class NfcException implements Exception {
  final String message;

  NfcException(this.message);

  @override
  String toString() => 'NfcException: $message';
}
