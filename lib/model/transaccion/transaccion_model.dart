
class TransaccionModel {
  static int _parseCount = 0;

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _parseIntLoose(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
  final int id;
  final String? numeroSerieMonedero;
  final String? nombrePasajero;
  final String? apellidoPaternoPasajero;
  final String? apellidoMaternoPasajero;
  final String? nombreCompletoPasajero;
  final String? clienteNombre;
  final DateTime? fechaHora;
  final String? tipoTransaccion;
  final double? monto;
  /// 0 = cobro con tarjeta física, distinto de 0 = cobro con código QR (GET /transacciones/paginado).
  final int? esQR;
  /// Ubicación inicial del viaje (opcional, desde API)
  final double? latitudInicial;
  final double? longitudInicial;
  /// Ubicación final del viaje (opcional, desde API)
  final double? latitudFinal;
  final double? longitudFinal;
  /// Método de pago (ej. Tarjeta, QR) desde API
  final String? nombreMetodoPago;

  TransaccionModel({
    required this.id,
    this.numeroSerieMonedero,
    this.nombrePasajero,
    this.apellidoPaternoPasajero,
    this.apellidoMaternoPasajero,
    this.nombreCompletoPasajero,
    this.clienteNombre,
    this.fechaHora,
    this.tipoTransaccion,
    this.monto,
    this.esQR,
    this.latitudInicial,
    this.longitudInicial,
    this.latitudFinal,
    this.longitudFinal,
    this.nombreMetodoPago,
  });

  factory TransaccionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Logging detallado solo para la primera transacción para evitar spam
      final isFirst = _parseCount == 0;
      _parseCount++;
      
      if (isFirst) {
      }
      // Construir el nombre del cliente desde los campos individuales si no viene completo
      String? clienteNombre;
      if (json['clienteNombre'] != null && json['clienteNombre'].toString().isNotEmpty) {
        clienteNombre = json['clienteNombre'].toString();
      } else if (json['nombreCliente'] != null) {
        final partes = [
          json['nombreCliente']?.toString(),
          json['apellidoPaternoCliente']?.toString(),
          json['apellidoMaternoCliente']?.toString(),
        ].where((parte) => parte != null && parte.isNotEmpty).toList();
        clienteNombre = partes.isEmpty ? null : partes.join(' ');
      }

      // Leer fechaHoraFinal primero, luego fechaHora como fallback
      // Las fechas del servidor vienen en UTC, así que las parseamos como UTC
      DateTime? fechaHora;
      String? fechaStr;
      if (json['fechaHoraFinal'] != null) {
        fechaStr = json['fechaHoraFinal'].toString();
      } else if (json['fechaHora'] != null) {
        fechaStr = json['fechaHora'].toString();
      } else if (json['fhRegistro'] != null) {
        fechaStr = json['fhRegistro'].toString();
      }
      
      if (fechaStr != null && fechaStr.isNotEmpty) {
        // Parsear la fecha - DateTime.tryParse debería manejar correctamente las fechas ISO 8601 con 'Z'
        fechaHora = DateTime.tryParse(fechaStr);
        
        // Verificar y corregir: si la fecha termina en 'Z' pero no está marcada como UTC,
        // significa que el parseo no funcionó correctamente y debemos forzar UTC
        if (fechaHora != null && fechaStr.endsWith('Z') && !fechaHora!.isUtc) {
          // Recrear la fecha como UTC usando los componentes parseados
          fechaHora = DateTime.utc(
            fechaHora!.year,
            fechaHora!.month,
            fechaHora!.day,
            fechaHora!.hour,
            fechaHora!.minute,
            fechaHora!.second,
            fechaHora!.millisecond,
            fechaHora!.microsecond,
          );
        }
      }

      // ID: alias típicos en APIs (evita descartar filas completas).
      final idRaw = json['id'] ??
          json['idTransaccion'] ??
          json['id_transaccion'] ??
          json['idTransaccionMonedero'];
      final idParsed = _parseIntLoose(idRaw);
      if (idParsed == null) {
        throw Exception(
            'Sin id reconocido (id / idTransaccion): keys=${json.keys.toList()}');
      }

      final tipoRaw = json['tipoTransaccion'] ?? json['tipo'] ?? json['tipoTransaccionNombre'];
      final montoRaw = json['monto'] ?? json['importe'] ?? json['total'];

      return TransaccionModel(
        id: idParsed,
        numeroSerieMonedero: json['numeroSerieMonedero']?.toString(),
        nombrePasajero: json['nombrePasajero']?.toString(),
        apellidoPaternoPasajero: json['apellidoPaternoPasajero']?.toString(),
        apellidoMaternoPasajero: json['apellidoMaternoPasajero']?.toString(),
        nombreCompletoPasajero: json['nombreCompletoPasajero']?.toString(),
        clienteNombre: clienteNombre,
        fechaHora: fechaHora,
        tipoTransaccion: tipoRaw?.toString(),
        monto: _parseDouble(montoRaw),
        esQR: _parseIntLoose(json['esQR'] ?? json['es_qr']),
        latitudInicial: _parseDouble(json['latitudInicial']),
        longitudInicial: _parseDouble(json['longitudInicial']),
        latitudFinal: _parseDouble(json['latitudFinal']),
        longitudFinal: _parseDouble(json['longitudFinal']),
        nombreMetodoPago: json['nombreMetodoPago']?.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroSerieMonedero': numeroSerieMonedero,
      'nombrePasajero': nombrePasajero,
      'apellidoPaternoPasajero': apellidoPaternoPasajero,
      'apellidoMaternoPasajero': apellidoMaternoPasajero,
      'nombreCompletoPasajero': nombreCompletoPasajero,
      'clienteNombre': clienteNombre,
      'fechaHora': fechaHora?.toIso8601String(),
      'tipoTransaccion': tipoTransaccion,
      'monto': monto,
      'esQR': esQR,
      'latitudInicial': latitudInicial,
      'longitudInicial': longitudInicial,
      'latitudFinal': latitudFinal,
      'longitudFinal': longitudFinal,
      'nombreMetodoPago': nombreMetodoPago,
    };
  }

  /// Obtiene el nombre completo del pasajero o retorna null si no hay pasajero
  String? get nombrePasajeroCompleto {
    // Si viene el nombre completo directamente, usarlo
    if (nombreCompletoPasajero != null && nombreCompletoPasajero!.isNotEmpty) {
      return nombreCompletoPasajero;
    }
    // Si no, construir el nombre completo desde las partes
    if (nombrePasajero != null && nombrePasajero!.isNotEmpty) {
      final partes = [
        nombrePasajero,
        apellidoPaternoPasajero,
        apellidoMaternoPasajero,
      ].where((parte) => parte != null && parte.isNotEmpty).toList();
      return partes.isEmpty ? null : partes.join(' ');
    }
    return null;
  }

  /// Verifica si es una recarga
  bool get esRecarga {
    return tipoTransaccion?.toUpperCase() == 'RECARGA';
  }

  /// Verifica si es un débito
  bool get esDebito {
    return tipoTransaccion?.toUpperCase() == 'DEBITO' ||
        tipoTransaccion?.toUpperCase() == 'DÉBITO';
  }
}

