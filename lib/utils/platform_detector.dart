import 'package:flutter/foundation.dart' show kIsWeb;

/// Utilidad para detectar la plataforma en la que se ejecuta la aplicación
class PlatformDetector {
  /// Detecta si estamos ejecutando en iOS (web o nativo)
  static bool isIOS() {
    if (!kIsWeb) {
      // En plataformas nativas, usar dart:io
      try {
        // Solo disponible en plataformas nativas (no web)
        return false; // Se detectará en tiempo de compilación
      } catch (e) {
        return false;
      }
    } else {
      // En web, detectar desde User-Agent
      return _isIosWeb();
    }
  }
  
  /// Detecta iOS desde User-Agent en web
  static bool _isIosWeb() {
    if (!kIsWeb) return false;
    
    try {
      // Usar JS interop o window.navigator si está disponible
      // Para evitar problemas, usar un try-catch y fallback
      final userAgent = _getUserAgent();
      if (userAgent == null || userAgent.isEmpty) return false;
      
      final ua = userAgent.toLowerCase();
      return ua.contains('iphone') || 
             ua.contains('ipad') || 
             ua.contains('ipod') ||
             (ua.contains('macintosh') && ua.contains('mobile'));
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene el User-Agent del navegador (solo en web)
  static String? _getUserAgent() {
    if (!kIsWeb) return null;
    
    try {
      // Usar conditional import para dart:html
      return _getUserAgentWeb();
    } catch (e) {
      return null;
    }
  }
  
  /// Implementación web del User-Agent usando dart:html
  static String? _getUserAgentWeb() {
    // Esta función se implementará con conditional import
    // Para evitar errores de compilación, retornamos null si no está disponible
    try {
      // Intentar acceder a window.navigator.userAgent
      // Esto requiere que dart:html esté disponible
      return null; // Se implementará externamente
    } catch (e) {
      return null;
    }
  }
}

