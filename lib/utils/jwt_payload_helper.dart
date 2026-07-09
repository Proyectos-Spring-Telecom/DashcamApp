import 'dart:convert';

/// Decodifica el payload de un JWT (sin validar firma; solo lectura de claims en cliente).
class JwtPayloadHelper {
  JwtPayloadHelper._();

  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return {};

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
      return {};
    } catch (_) {
      return {};
    }
  }
}
