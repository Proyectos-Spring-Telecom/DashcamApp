class GastoRecargaMesModel {
  final int mes;
  final int anio;
  final double totalGastado;
  final double totalRecargado;

  GastoRecargaMesModel({
    required this.mes,
    required this.anio,
    required this.totalGastado,
    required this.totalRecargado,
  });

  factory GastoRecargaMesModel.fromJson(Map<String, dynamic> json) {
    return GastoRecargaMesModel(
      mes: json['mes'] as int? ?? 0,
      anio: json['anio'] as int? ?? 0,
      totalGastado: (json['totalGastado'] as num?)?.toDouble() ?? 0.0,
      totalRecargado: (json['totalRecargado'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'anio': anio,
      'totalGastado': totalGastado,
      'totalRecargado': totalRecargado,
    };
  }
}

