class CodigoPostalModel {
  final String estado;
  final String estadoAbreviatura;
  final String municipio;
  final String centroReparto;
  final String codigoPostal;
  final List<String> colonias;

  CodigoPostalModel({
    required this.estado,
    required this.estadoAbreviatura,
    required this.municipio,
    required this.centroReparto,
    required this.codigoPostal,
    required this.colonias,
  });

  factory CodigoPostalModel.fromJson(Map<String, dynamic> json) {
    return CodigoPostalModel(
      estado: json['estado']?.toString() ?? '',
      estadoAbreviatura: json['estado_abreviatura']?.toString() ?? '',
      municipio: json['municipio']?.toString() ?? '',
      centroReparto: json['centro_reparto']?.toString() ?? '',
      codigoPostal: json['codigo_postal']?.toString() ?? '',
      colonias: (json['colonias'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'estado_abreviatura': estadoAbreviatura,
      'municipio': municipio,
      'centro_reparto': centroReparto,
      'codigo_postal': codigoPostal,
      'colonias': colonias,
    };
  }
}

class CodigoPostalResponse {
  final bool error;
  final String message;
  final CodigoPostalModel? codigoPostal;

  CodigoPostalResponse({
    required this.error,
    required this.message,
    this.codigoPostal,
  });

  factory CodigoPostalResponse.fromJson(Map<String, dynamic> json) {
    return CodigoPostalResponse(
      error: json['error'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      codigoPostal: json['codigo_postal'] != null
          ? CodigoPostalModel.fromJson(
              json['codigo_postal'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'codigo_postal': codigoPostal?.toJson(),
    };
  }
}

