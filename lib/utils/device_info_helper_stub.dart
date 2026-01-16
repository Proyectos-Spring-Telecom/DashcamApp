// Stub para plataformas que no son web
// Este archivo se usa cuando dart:html no está disponible

class BrowserInfoHelper {
  static Map<String, dynamic> getBrowserInfo() {
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
