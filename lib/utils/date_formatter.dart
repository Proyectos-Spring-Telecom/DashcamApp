import 'package:intl/intl.dart';

class DateFormatter {
  /// Formatea una fecha en formato "Miembro desde DD/MM/YYYY"
  /// Si includePrefix es false, solo retorna la fecha formateada
  static String formatMemberSinceDate(String? fechaCreacion, {bool includePrefix = true}) {
    if (fechaCreacion == null || fechaCreacion.isEmpty) {
      return includePrefix ? 'Miembro desde N/A' : 'N/A';
    }

    try {
      // Intentar parsear la fecha (puede venir en diferentes formatos)
      DateTime? fecha;
      
      // Intentar diferentes formatos comunes
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

      // Si no se pudo parsear, intentar parseo ISO directo
      if (fecha == null) {
        fecha = DateTime.tryParse(fechaCreacion);
      }

      if (fecha != null) {
        // Asegurar que solo se muestre la fecha sin hora
        final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
        final fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaSolo);
        return includePrefix ? 'Miembro desde $fechaFormateada' : fechaFormateada;
      }

      return includePrefix ? 'Miembro desde $fechaCreacion' : fechaCreacion;
    } catch (e) {
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

  /// Formatea una fecha con hora en formato "dd/MM/yyyy HH:mm:ss"
  static String formatDateTime(String? fechaCreacion) {
    if (fechaCreacion == null || fechaCreacion.isEmpty) {
      return 'N/A';
    }

    try {
      // Limpiar la cadena eliminando referencias a zonas horarias (GMT, UTC, etc.)
      String fechaLimpia = fechaCreacion
          .replaceAll(RegExp(r'GMT[+-]\d{4}'), '') // Eliminar GMT-0600, GMT+0500, etc.
          .replaceAll(RegExp(r'\(GMT[+-]\d{2}:\d{2}\)'), '') // Eliminar (GMT-06:00), etc.
          .replaceAll(RegExp(r'GMT[+-]\d{2}:\d{2}'), '') // Eliminar GMT-06:00, etc.
          .replaceAll(RegExp(r'UTC[+-]\d{2}:\d{2}'), '') // Eliminar UTC-06:00, etc.
          .replaceAll(RegExp(r'Z$'), '') // Eliminar Z al final
          .trim();
      
      DateTime? fecha;
      
      // Primero intentar parseo ISO directo (más robusto)
      fecha = DateTime.tryParse(fechaLimpia);
      
      // Si no funciona, intentar diferentes formatos comunes
      if (fecha == null) {
        final formatos = [
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-ddTHH:mm:ss.SSS',
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-dd',
          'dd/MM/yyyy HH:mm:ss',
          'dd/MM/yyyy',
          'MM/dd/yyyy',
        ];

        for (final formato in formatos) {
          try {
            fecha = DateFormat(formato).parse(fechaLimpia);
            break;
          } catch (e) {
            continue;
          }
        }
      }

      if (fecha != null) {
        // Formatear con fecha y hora en formato 12 horas con AM/PM (sin zona horaria)
        return DateFormat('dd/MM/yyyy hh:mm:ss a', 'es').format(fecha);
      }

      // Si no se pudo parsear, retornar el valor original sin zona horaria
      return fechaLimpia;
    } catch (e) {
      // En caso de error, retornar el valor original sin zona horaria
      return fechaCreacion
          .replaceAll(RegExp(r'GMT[+-]\d{4}'), '')
          .replaceAll(RegExp(r'\(GMT[+-]\d{2}:\d{2}\)'), '')
          .replaceAll(RegExp(r'GMT[+-]\d{2}:\d{2}'), '')
          .trim();
    }
  }
}

