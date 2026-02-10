import 'package:email_validator/email_validator.dart';

/// Validación de correo electrónico compartida (Registro, Agregar método de pago).
/// Usa el paquete [email_validator] para validar formato.

/// Devuelve true si [email] tiene formato de correo válido.
bool isValidEmail(String email) {
  return EmailValidator.validate(email.trim());
}
