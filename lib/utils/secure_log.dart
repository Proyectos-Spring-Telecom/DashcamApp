import 'package:flutter/foundation.dart';

/// Utilidades de logging seguro (solo debug). No imprime secretos completos.
class SecureLog {
  SecureLog._();

  static void d(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static void dToken(String label, String? token) {
    if (!kDebugMode) return;
  }

  static void dAuth(String label, {required bool present}) {
    if (!kDebugMode) return;
  }

  static String redact(String? value, {int visibleEdges = 4}) {
    if (value == null || value.isEmpty) return '[vacío]';
    if (value.length <= visibleEdges * 2) return '[redactado]';
    return '${value.substring(0, visibleEdges)}…'
        '${value.substring(value.length - visibleEdges)}';
  }

  static Map<String, dynamic> redactHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    for (final key in copy.keys.toList()) {
      if (key.toLowerCase() == 'authorization') {
        copy[key] = '[redactado]';
      }
    }
    return copy;
  }
}
