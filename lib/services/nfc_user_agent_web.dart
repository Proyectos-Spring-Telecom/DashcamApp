/// Implementación web para obtener User-Agent
/// Este archivo solo se importa cuando se compila para web
import 'dart:html' as html show window;

String? getUserAgent() {
  try {
    return html.window.navigator.userAgent;
  } catch (e) {
    return null;
  }
}

