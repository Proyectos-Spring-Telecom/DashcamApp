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

  /// Formatea una fecha con hora en formato "dd-MM-yyyy hh:mm a" (formato estándar)
  /// Si la fecha es UTC, usa los componentes UTC directamente sin convertir a hora local
  static String formatDateTime(String? fechaCreacion) {
    if (fechaCreacion == null || fechaCreacion.isEmpty) {
      return 'N/A';
    }

    try {
      // Parsear la fecha directamente (puede venir en diferentes formatos)
      DateTime? fecha = DateTime.tryParse(fechaCreacion);
      
      // Si no funciona, intentar diferentes formatos comunes
      if (fecha == null) {
        // Limpiar la cadena eliminando referencias a zonas horarias
        String fechaLimpia = fechaCreacion
            .replaceAll(RegExp(r'GMT[+-]\d{4}'), '')
            .replaceAll(RegExp(r'\(GMT[+-]\d{2}:\d{2}\)'), '')
            .replaceAll(RegExp(r'GMT[+-]\d{2}:\d{2}'), '')
            .replaceAll(RegExp(r'UTC[+-]\d{2}:\d{2}'), '')
            .replaceAll(RegExp(r'Z$'), '')
            .trim();
        
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
        // Extraer los componentes de fecha y hora (usar UTC si la fecha es UTC)
        int year, month, day, hour, minute;
        
        if (fecha.isUtc) {
          // Usar componentes UTC directamente
          year = fecha.year;
          month = fecha.month;
          day = fecha.day;
          hour = fecha.hour;
          minute = fecha.minute;
        } else {
          // Convertir a local y usar esos componentes
          final fechaLocal = fecha.toLocal();
          year = fechaLocal.year;
          month = fechaLocal.month;
          day = fechaLocal.day;
          hour = fechaLocal.hour;
          minute = fechaLocal.minute;
        }
        
        // Formatear manualmente para evitar problemas de zona horaria
        final hora12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final amPm = hour >= 12 ? 'PM' : 'AM';
        
        return '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year ${hora12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
      }

      // Si no se pudo parsear, retornar el valor original
      return fechaCreacion;
    } catch (e) {
      // En caso de error, retornar el valor original
      return fechaCreacion;
    }
  }
  
  /// Formatea una fecha con hora desde un DateTime (formato estándar)
  /// Si la fecha es UTC, usa los componentes UTC directamente sin convertir a hora local
  static String formatDateTimeFromDateTime(DateTime? fecha) {
    if (fecha == null) {
      return 'N/A';
    }

    try {
      // Extraer los componentes de fecha y hora (usar UTC si la fecha es UTC)
      int year, month, day, hour, minute;
      
      if (fecha.isUtc) {
        // Usar componentes UTC directamente
        year = fecha.year;
        month = fecha.month;
        day = fecha.day;
        hour = fecha.hour;
        minute = fecha.minute;
      } else {
        // Convertir a local y usar esos componentes
        final fechaLocal = fecha.toLocal();
        year = fechaLocal.year;
        month = fechaLocal.month;
        day = fechaLocal.day;
        hour = fechaLocal.hour;
        minute = fechaLocal.minute;
      }
      
      // Formatear manualmente para evitar problemas de zona horaria
      final hora12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      
      return '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year ${hora12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
    } catch (e) {
      return 'N/A';
    }
  }
}

