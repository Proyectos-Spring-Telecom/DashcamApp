class ExtravioReportRequest {
  final String correo;
  final String numeroSerie;

  ExtravioReportRequest({
    required this.correo,
    required this.numeroSerie,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'numeroSerie': numeroSerie,
    };
  }
}
