class TransaccionRequest {
  final String tipoTransaccion;
  final double monto;
  final double? latitud;
  final double? longitud;
  final String fechaHora;
  final String numeroSerieMonedero;
  final String? numeroSerieValidador;

  TransaccionRequest({
    required this.tipoTransaccion,
    required this.monto,
    this.latitud,
    this.longitud,
    required this.fechaHora,
    required this.numeroSerieMonedero,
    this.numeroSerieValidador,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipoTransaccion': tipoTransaccion,
      'monto': monto,
      'latitud': latitud,
      'longitud': longitud,
      'fechaHora': fechaHora,
      'numeroSerieMonedero': numeroSerieMonedero,
      'numeroSerieValidador': numeroSerieValidador,
    };
  }
}

