import 'package:flutter/services.dart';

/// Utilidad compartida para campos que solo aceptan letras (incl. acentos, ñ, ü) y espacios.
/// Usado en Registro y Agregar método de pago (Nombre(s), Apellido(s)).
/// No acepta números ni caracteres especiales.

/// Regex para validar que una cadena contiene solo letras y espacios.
final RegExp soloLetrasRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]*$');

/// Formatters para usar en [TextFormField.inputFormatters]; bloquea números y caracteres especiales.
final List<TextInputFormatter> soloLetrasInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
];

/// Devuelve true si [value] está vacío o contiene solo letras (y espacios).
bool isSoloLetras(String value) {
  return value.isEmpty || soloLetrasRegex.hasMatch(value);
}
