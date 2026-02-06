import 'package:flutter/foundation.dart';

class TransaccionModel {
  static int _parseCount = 0;
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
  });

  factory TransaccionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Logging detallado solo para la primera transacción para evitar spam
      final isFirst = _parseCount == 0;
      _parseCount++;
      
      if (isFirst) {
        debugPrint('🔍 Parseando primera transacción. Keys disponibles: ${json.keys.toList()}');
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

      // Validar que el ID exista
      final id = json['id'];
      if (id == null) {
        throw Exception('El campo "id" es requerido en la transacción');
      }

      return TransaccionModel(
        id: id is int ? id : int.tryParse(id.toString()) ?? 0,
        numeroSerieMonedero: json['numeroSerieMonedero']?.toString(),
        nombrePasajero: json['nombrePasajero']?.toString(),
        apellidoPaternoPasajero: json['apellidoPaternoPasajero']?.toString(),
        apellidoMaternoPasajero: json['apellidoMaternoPasajero']?.toString(),
        nombreCompletoPasajero: json['nombreCompletoPasajero']?.toString(),
        clienteNombre: clienteNombre,
        fechaHora: fechaHora,
        tipoTransaccion: json['tipoTransaccion']?.toString(),
        monto: json['monto'] != null ? (json['monto'] as num).toDouble() : null,
        esQR: json['esQR'] != null
            ? (json['esQR'] is num ? (json['esQR'] as num).toInt() : int.tryParse(json['esQR'].toString()))
            : null,
      );
    } catch (e) {
      // Si hay un error al parsear, loguearlo pero continuar con valores por defecto
      print('⚠️ Error al parsear TransaccionModel: $e');
      print('⚠️ JSON recibido: $json');
      rethrow; // Relanzar para que el servicio pueda manejarlo
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

