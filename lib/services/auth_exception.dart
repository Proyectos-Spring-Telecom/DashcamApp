/// Excepción personalizada para errores de autenticación.
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
