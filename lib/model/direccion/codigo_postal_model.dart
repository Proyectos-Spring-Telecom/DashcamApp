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
    final estadoRaw = json['estado'];
    final municipioRaw = json['municipio'];
    final coloniasRaw = json['colonias'];

    String _parseNombre(dynamic value) {
      if (value is Map) {
        return value['nombre']?.toString() ?? '';
      }
      return value?.toString() ?? '';
    }

    String _parseEstadoAbreviatura(dynamic value) {
      if (value is Map) {
        return value['abreviatura']?.toString() ??
            value['clave']?.toString() ??
            '';
      }
      return '';
    }

    List<String> _parseColonias(dynamic value) {
      if (value is! List) return [];
      return value
          .map((item) {
            if (item is Map) {
              return item['nombre']?.toString() ?? '';
            }
            return item?.toString() ?? '';
          })
          .where((nombre) => nombre.isNotEmpty)
          .toList();
    }

    return CodigoPostalModel(
      estado: _parseNombre(estadoRaw),
      estadoAbreviatura: json['estado_abreviatura']?.toString() ??
          _parseEstadoAbreviatura(estadoRaw),
      municipio: _parseNombre(municipioRaw),
      centroReparto: json['centro_reparto']?.toString() ??
          json['ciudad']?['nombre']?.toString() ??
          '',
      codigoPostal:
          json['codigo_postal']?.toString() ?? json['codigoPostal']?.toString() ?? '',
      colonias: _parseColonias(coloniasRaw),
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
    final tieneEnvelope =
        json.containsKey('error') || json.containsKey('message') || json.containsKey('codigo_postal');

    // Nuevo formato: respuesta directa del CP sin envelope.
    final esPayloadDirecto = json.containsKey('codigoPostal') &&
        json.containsKey('estado') &&
        json.containsKey('municipio');

    return CodigoPostalResponse(
      error: json['error'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      codigoPostal: tieneEnvelope
          ? (json['codigo_postal'] != null
              ? CodigoPostalModel.fromJson(
                  json['codigo_postal'] as Map<String, dynamic>)
              : null)
          : (esPayloadDirecto ? CodigoPostalModel.fromJson(json) : null),
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

