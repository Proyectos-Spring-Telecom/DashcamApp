import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración central de variables de entorno.
/// Requiere que dotenv.load() se haya llamado en main() antes de usar.
/// Nunca hardcodear secretos aquí; todos vienen de .env (no trackeado en Git).
class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL']?.trim() ?? '';

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? '';

  static String get netpayPublicApiKey =>
      dotenv.env['NETPAY_PUBLIC_API_KEY']?.trim() ?? '';
}
