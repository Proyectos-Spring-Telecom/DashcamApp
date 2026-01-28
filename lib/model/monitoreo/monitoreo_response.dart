import 'package:dashboardpro/model/monitoreo/unidad_model.dart';

/// * Modelo para la respuesta del endpoint GET /monitoreo
/// Contiene un arreglo de unidades (vehículos) filtradas por cliente
class MonitoreoResponse {
  final List<UnidadModel> data;

  MonitoreoResponse({
    required this.data,
  });

  factory MonitoreoResponse.fromJson(Map<String, dynamic> json) {
    return MonitoreoResponse(
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) => UnidadModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((unidad) => unidad.toJson()).toList(),
    };
  }

  /// * Obtiene solo las unidades con posición válida
  List<UnidadModel> get unidadesConPosicionValida {
    return data.where((unidad) => unidad.tienePosicionValida).toList();
  }

  /// * Obtiene solo las unidades en ruta
  List<UnidadModel> get unidadesEnRuta {
    return data.where((unidad) => unidad.estaEnRuta).toList();
  }
}
