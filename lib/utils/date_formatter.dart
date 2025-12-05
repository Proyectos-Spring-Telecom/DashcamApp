import 'package:intl/intl.dart';

class DateFormatter {
  /// Formatea una fecha en formato "Miembro desde DD/MM/YYYY"
  /// Si includePrefix es false, solo retorna la fecha formateada
  static String formatMemberSinceDate(String? fechaCreacion, {bool includePrefix = true}) {
    if (fechaCreacion == null || fechaCreacion.isEmpty) {
      return includePrefix ? 'Miembro desde N/A' : 'N/A';
    }

    try {
      DateTime? fecha;
      
      // Primero intentar parseo ISO directo (más robusto)
      fecha = DateTime.tryParse(fechaCreacion);
      
      // Si no funciona, intentar diferentes formatos comunes
      if (fecha == null) {
        final formatos = [
          'yyyy-MM-dd',
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-ddTHH:mm:ssZ',
          'yyyy-MM-dd HH:mm:ss',
          'dd/MM/yyyy',
          'MM/dd/yyyy',
        ];

        for (final formato in formatos) {
          try {
            fecha = DateFormat(formato).parse(fechaCreacion);
            break;
          } catch (e) {
            continue;
          }
        }
      }

      if (fecha != null) {
        // Asegurar que solo se muestre la fecha sin hora
        // Normalizar la fecha a medianoche para eliminar cualquier componente de hora
        final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
        final fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaSolo);
        return includePrefix ? 'Miembro desde $fechaFormateada' : fechaFormateada;
      }

      // Si no se pudo parsear, retornar el valor original
      return includePrefix ? 'Miembro desde $fechaCreacion' : fechaCreacion;
    } catch (e) {
      // En caso de error, retornar el valor original
      return includePrefix ? 'Miembro desde $fechaCreacion' : fechaCreacion;
    }
  }

  /// Formatea una fecha para mostrar solo el año
  static String formatYearOnly(String? fechaCreacion) {
    if (fechaCreacion == null || fechaCreacion.isEmpty) {
      return 'N/A';
    }

    try {
      DateTime? fecha = DateTime.tryParse(fechaCreacion);
      if (fecha != null) {
        return DateFormat('yyyy').format(fecha);
      }
      return fechaCreacion;
    } catch (e) {
      return fechaCreacion;
    }
  }
}

