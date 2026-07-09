import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Carga configuración no sensible empaquetada. Secretos vía [--dart-define] o [--dart-define-from-file].
Future<void> loadAppEnv() async {
  try {
    await dotenv.load(fileName: 'assets/config/env.defaults');
  } catch (e) {
  }
}
