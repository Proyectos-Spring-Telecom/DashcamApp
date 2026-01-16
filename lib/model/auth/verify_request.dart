class VerifyRequest {
  final String codigo;

  VerifyRequest({
    required this.codigo,
  });

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
    };
  }
}

