class ChangePasswordRequest {
  final String passwordActual;
  final String passwordNueva;
  final String passwordNuevaConfirmacion;

  ChangePasswordRequest({
    required this.passwordActual,
    required this.passwordNueva,
    required this.passwordNuevaConfirmacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'passwordActual': passwordActual,
      'passwordNueva': passwordNueva,
      'passwordNuevaConfirmacion': passwordNuevaConfirmacion,
    };
  }
}

