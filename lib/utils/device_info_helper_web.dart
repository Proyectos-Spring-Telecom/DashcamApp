// Implementación web usando dart:html
import 'dart:html' as html;

class BrowserInfoHelper {
  static Map<String, dynamic> getBrowserInfo() {
    try {
      final window = html.window;
      final screen = window.screen;
      final navigator = window.navigator;
      
      // Obtener idioma
      final language = navigator.language ?? 'es';
      
      // Obtener información de pantalla
      final screenWidth = screen?.width?.toDouble() ?? 0;
      final screenHeight = screen?.height?.toDouble() ?? 0;
      final colorDepth = screen?.colorDepth ?? 24;
      
      // Java está deshabilitado por defecto en navegadores modernos
      bool javaEnabled = false;
      
      // Calcular diferencia horaria (en minutos)
      final now = DateTime.now();
      final utcNow = now.toUtc();
      final timeDifference = now.difference(utcNow).inMinutes;
      
      return {
        'language': language,
        'javaEnabled': javaEnabled,
        'timeDifference': timeDifference,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'colorDepth': colorDepth,
      };
    } catch (e) {
      return {
        'language': 'es',
        'javaEnabled': false,
        'timeDifference': 0,
        'screenWidth': 0,
        'screenHeight': 0,
        'colorDepth': 24,
      };
    }
  }
}
