import 'package:flutter/material.dart';

/// Reglas compartidas de contraseña (login, registro, cambio de contraseña).
class PasswordRules {
  PasswordRules._();

  static const int minLength = 12;
  static const int maxLength = 16;

  static final RegExp lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp numberRegex = RegExp(r'[0-9]');
  static final RegExp symbolRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  static PasswordRulesStatus evaluate(String password) {
    return PasswordRulesStatus(
      hasValidLength:
          password.length >= minLength && password.length <= maxLength,
      hasNoSpaces: !password.contains(' '),
      hasLowercase: lowercaseRegex.hasMatch(password),
      hasNumber: numberRegex.hasMatch(password),
      hasSymbol: symbolRegex.hasMatch(password),
    );
  }

  static bool isValid(String password) => evaluate(password).allPassed;

  static String? validate(
    String? value, {
    String emptyMessage = 'Por favor ingresa tu contraseña',
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage;
    }
    if (value.length < minLength || value.length > maxLength) {
      return 'La contraseña debe tener entre $minLength y $maxLength caracteres';
    }
    if (value.contains(' ')) {
      return 'La contraseña no puede contener espacios';
    }
    if (!lowercaseRegex.hasMatch(value)) {
      return 'La contraseña debe tener al menos una minúscula';
    }
    if (!numberRegex.hasMatch(value)) {
      return 'La contraseña debe tener al menos un número';
    }
    if (!symbolRegex.hasMatch(value)) {
      return 'La contraseña debe incluir al menos un símbolo';
    }
    return null;
  }

  static String? validateConfirmation(
    String? value,
    String password, {
    String emptyMessage = 'Por favor confirma tu contraseña',
  }) {
    final rulesError = validate(value, emptyMessage: emptyMessage);
    if (rulesError != null) return rulesError;
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }
}

class PasswordRulesStatus {
  const PasswordRulesStatus({
    required this.hasValidLength,
    required this.hasNoSpaces,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSymbol,
  });

  final bool hasValidLength;
  final bool hasNoSpaces;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSymbol;

  bool get allPassed =>
      hasValidLength && hasNoSpaces && hasLowercase && hasNumber && hasSymbol;

  int get passedCount => [
        hasValidLength,
        hasNoSpaces,
        hasLowercase,
        hasNumber,
        hasSymbol,
      ].where((rule) => rule).length;

  int get activeLightIndex {
    if (allPassed || passedCount >= 5) return 2;
    if (passedCount >= 3) return 1;
    return 0;
  }

  Color get strengthColor {
    if (allPassed) return const Color(0xFF66BB6A);
    if (passedCount >= 3) return const Color(0xFFFFB300);
    return const Color(0xFFFF5252);
  }

  String get strengthLabel {
    if (allPassed) return 'Segura';
    if (passedCount >= 4) return 'Casi segura';
    if (passedCount >= 3) return 'Regular';
    return 'Poco segura';
  }

  String? get nextStepMessage {
    if (allPassed) return null;
    if (!hasValidLength) {
      return 'La contraseña debe tener entre ${PasswordRules.minLength} y '
          '${PasswordRules.maxLength} caracteres.';
    }
    if (!hasNoSpaces) return 'La contraseña no puede contener espacios.';
    if (!hasLowercase) {
      return 'La contraseña debe tener al menos una minúscula.';
    }
    if (!hasNumber) return 'La contraseña debe tener al menos un número.';
    if (!hasSymbol) return 'La contraseña debe incluir al menos un símbolo.';
    return null;
  }
}
