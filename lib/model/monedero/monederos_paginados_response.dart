import 'package:dashboardpro/model/monedero/monedero_model.dart';
import 'package:dashboardpro/model/transaccion/paginacion_model.dart';

class MonederosPaginadosResponse {
  final List<MonederoModel> data;
  final PaginacionModel paginacion;

  MonederosPaginadosResponse({
    required this.data,
    required this.paginacion,
  });

  factory MonederosPaginadosResponse.fromJson(Map<String, dynamic> json) {
    List<MonederoModel> monederos = [];
    
    if (json['data'] != null && json['data'] is List) {
      final dataList = json['data'] as List<dynamic>;
      for (var i = 0; i < dataList.length; i++) {
        try {
          final item = dataList[i];
          if (item is Map<String, dynamic>) {
            final monedero = MonederoModel.fromJson(item);
            monederos.add(monedero);
          } else {
          }
        } catch (e, stackTrace) {
        }
      }
    }

    PaginacionModel paginacion;
    if (json['paginated'] != null && json['paginated'] is Map<String, dynamic>) {
      paginacion = PaginacionModel.fromJson(json['paginated'] as Map<String, dynamic>);
    } else {
      // Si no hay información de paginación, crear una por defecto
      paginacion = PaginacionModel(
        total: monederos.length,
        page: 1,
        lastPage: 1,
      );
    }

    return MonederosPaginadosResponse(
      data: monederos,
      paginacion: paginacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((monedero) => monedero.toJson()).toList(),
      'paginated': paginacion.toJson(),
    };
  }
}

