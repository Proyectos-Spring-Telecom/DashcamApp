class GastoMesModel {
  final int mes;
  final int anio;
  final double total;

  GastoMesModel({
    required this.mes,
    required this.anio,
    required this.total,
  });

  factory GastoMesModel.fromJson(Map<String, dynamic> json) {
    return GastoMesModel(
      mes: json['mes'] as int? ?? 0,
      anio: json['anio'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'anio': anio,
      'total': total,
    };
  }
}

