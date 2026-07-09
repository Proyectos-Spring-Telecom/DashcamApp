import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración central de variables de entorno.
///
/// Prioridad: [--dart-define] > [dotenv / assets/config/env.defaults] > fallback seguro.
/// Google Maps en Web: mantener [--dart-define=GOOGLE_MAPS_API_KEY=...] en el build.
///
/// Nota: [String.fromEnvironment] debe ser `const` con nombre literal (no dinámico).
class EnvConfig {
  EnvConfig._();

  static const String _defaultApiBaseUrl = 'https://dashcampay.com/apipay';

  static const String _apiBaseUrlDefine =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String _authApiBaseUrlDefine =
      String.fromEnvironment('AUTH_API_BASE_URL', defaultValue: '');
  static const String _googleMapsApiKeyDefine =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
  static const String _netpayPublicApiKeyDefine =
      String.fromEnvironment('NETPAY_PUBLIC_API_KEY', defaultValue: '');
  static const String _appEnvDefine =
      String.fromEnvironment('APP_ENV', defaultValue: '');
  static const bool _webDevProxyEnabled =
      bool.fromEnvironment('WEB_USE_DEV_PROXY', defaultValue: true);
  static const int _webDevProxyPort =
      int.fromEnvironment('WEB_DEV_PROXY_PORT', defaultValue: 8090);

  /// `true` cuando Flutter Web en localhost redirige al proxy CORS local.
  static bool get usesWebDevProxy {
    if (!_webDevProxyEnabled || !kIsWeb || !kDebugMode) return false;
    final host = Uri.base.host;
    return host == 'localhost' || host == '127.0.0.1' || host.isEmpty;
  }

  static String get webDevProxyUrl =>
      'http://127.0.0.1:$_webDevProxyPort/apipay';

  static String _fromDotenv(String key) => dotenv.env[key]?.trim() ?? '';

  static String _resolveConfiguredApiBaseUrl() {
    final fromDefine = _apiBaseUrlDefine.trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromFile = _fromDotenv('API_BASE_URL');
    if (fromFile.isNotEmpty) return fromFile;
    return _defaultApiBaseUrl;
  }

  /// En Flutter Web sobre localhost, el navegador bloquea llamadas directas a
  /// dashcampay.com (CORS). Usar proxy local [tool/dev_api_proxy.dart].
  static String _applyWebDevProxyIfNeeded(String configuredUrl) {
    if (!_webDevProxyEnabled || !kIsWeb || !kDebugMode) {
      return configuredUrl;
    }

    final host = Uri.base.host;
    final isLocalDev =
        host == 'localhost' || host == '127.0.0.1' || host.isEmpty;
    if (!isLocalDev) return configuredUrl;

    return 'http://127.0.0.1:$_webDevProxyPort/apipay';
  }

  /// URL configurada sin redirección al proxy (p. ej. https://dashcampay.com/apipay).
  static String get configuredApiBaseUrl => _resolveConfiguredApiBaseUrl();

  static String get apiBaseUrl {
    return _applyWebDevProxyIfNeeded(_resolveConfiguredApiBaseUrl());
  }

  /// Base URL del servicio de autenticación (login, refresh, etc.).
  /// Si no se define [AUTH_API_BASE_URL], usa [apiBaseUrl].
  static String get authApiBaseUrl {
    final fromDefine = _authApiBaseUrlDefine.trim();
    if (fromDefine.isNotEmpty) {
      return _applyWebDevProxyIfNeeded(fromDefine);
    }
    final fromFile = _fromDotenv('AUTH_API_BASE_URL');
    if (fromFile.isNotEmpty) {
      return _applyWebDevProxyIfNeeded(fromFile);
    }
    return apiBaseUrl;
  }

  static String get googleMapsApiKey {
    final fromDefine = _googleMapsApiKeyDefine.trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromDotenv('GOOGLE_MAPS_API_KEY');
  }

  /// Llave pública NetPay (pk_*). Nunca usar sk_* en el cliente.
  static String get netpayPublicApiKey {
    final fromDefine = _netpayPublicApiKeyDefine.trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    return _fromDotenv('NETPAY_PUBLIC_API_KEY');
  }

  static String get appEnv {
    final fromDefine = _appEnvDefine.trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromFile = _fromDotenv('APP_ENV');
    if (fromFile.isNotEmpty) return fromFile;
    return 'development';
  }
}
