import 'package:dashboardpro/model/transaccion/transaccion_model.dart';
import 'package:dashboardpro/model/transaccion/paginacion_model.dart';
import 'package:flutter/foundation.dart';

class TransaccionesResponse {
  final List<TransaccionModel> data;
  final PaginacionModel paginacion;

  TransaccionesResponse({
    required this.data,
    required this.paginacion,
  });

  factory TransaccionesResponse.fromJson(Map<String, dynamic> json) {
    List<TransaccionModel> transacciones = [];
    
    if (json['data'] != null && json['data'] is List) {
      final dataList = json['data'] as List<dynamic>;
      debugPrint('🔄 Parseando ${dataList.length} transacciones...');
      for (var i = 0; i < dataList.length; i++) {
        try {
          final item = dataList[i];
          if (item is Map<String, dynamic>) {
            final transaccion = TransaccionModel.fromJson(item);
            transacciones.add(transaccion);
            if (i == 0) {
              debugPrint('✅ Primera transacción parseada - ID: ${transaccion.id}, Tipo: ${transaccion.tipoTransaccion}');
            }
          } else {
            debugPrint('⚠️ Item $i no es un Map, es: ${item.runtimeType}, valor: $item');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error al parsear transacción en índice $i: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          debugPrint('❌ Datos del item: ${dataList[i]}');
          // Continuar con las demás transacciones
        }
      }
      debugPrint('✅ Transacciones parseadas exitosamente: ${transacciones.length}/${dataList.length}');
    } else {
      debugPrint('⚠️ data es null o no es una lista');
      debugPrint('⚠️ Tipo de data: ${json['data']?.runtimeType}');
      debugPrint('⚠️ Valor de data: ${json['data']}');
    }
    
    // Parsear paginación
    PaginacionModel paginacion;
    if (json['paginated'] != null && json['paginated'] is Map<String, dynamic>) {
      try {
        paginacion = PaginacionModel.fromJson(json['paginated'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('❌ Error al parsear paginated: $e');
        paginacion = PaginacionModel(total: 0, page: 1, lastPage: 1);
      }
    } else {
      paginacion = PaginacionModel(total: 0, page: 1, lastPage: 1);
    }
    
    return TransaccionesResponse(
      data: transacciones,
      paginacion: paginacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'paginated': paginacion.toJson(),
    };
  }
}

