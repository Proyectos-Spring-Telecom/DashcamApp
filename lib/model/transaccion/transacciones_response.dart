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

    debugPrint('🔄 [TransaccionesResponse] Keys en JSON: ${json.keys.toList()}');

    // Listado: prioridad `data`, luego alias comunes del backend
    List<dynamic>? dataList;
    if (json['data'] is List) {
      dataList = json['data'] as List<dynamic>;
    } else if (json['items'] is List) {
      dataList = json['items'] as List<dynamic>;
    } else if (json['transacciones'] is List) {
      dataList = json['transacciones'] as List<dynamic>;
    }

    if (dataList != null) {
      debugPrint('🔄 Parseando ${dataList.length} transacciones (lista cruda)...');
      for (var i = 0; i < dataList.length; i++) {
        try {
          final item = dataList[i];
          if (item is Map) {
            final asMap = Map<String, dynamic>.from(item as Map);
            final transaccion = TransaccionModel.fromJson(asMap);
            transacciones.add(transaccion);
            if (i == 0) {
              debugPrint(
                  '✅ Primera transacción parseada - ID: ${transaccion.id}, Tipo: ${transaccion.tipoTransaccion}');
            }
          } else {
            debugPrint(
                '⚠️ Item $i no es un Map, es: ${item.runtimeType}, valor: $item');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error al parsear transacción en índice $i: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          debugPrint('❌ Datos del item: ${dataList[i]}');
        }
      }
      debugPrint(
          '✅ Transacciones parseadas exitosamente: ${transacciones.length}/${dataList.length}');
    } else {
      debugPrint('⚠️ Sin lista reconocida (data / items / transacciones)');
      debugPrint('⚠️ Tipo de data: ${json['data']?.runtimeType}');
    }

    // Paginación: `paginated` (contrato actual) o alias
    PaginacionModel paginacion;
    Map<String, dynamic>? pagMap;
    if (json['paginated'] is Map) {
      pagMap = Map<String, dynamic>.from(json['paginated'] as Map);
    } else if (json['pagination'] is Map) {
      pagMap = Map<String, dynamic>.from(json['pagination'] as Map);
    }

    if (pagMap != null) {
      try {
        paginacion = PaginacionModel.fromJson(pagMap);
      } catch (e) {
        debugPrint('❌ Error al parsear paginación: $e');
        paginacion = PaginacionModel(total: 0, page: 1, lastPage: 1);
      }
    } else {
      // Inferir desde el tamaño de la lista si no viene bloque de paginación
      final inferredTotal = transacciones.length;
      paginacion = PaginacionModel(
        total: inferredTotal,
        page: 1,
        lastPage: 1,
      );
      debugPrint(
          '📄 Sin objeto paginated; usando total inferido: $inferredTotal');
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

