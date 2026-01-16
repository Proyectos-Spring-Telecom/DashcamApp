import 'package:dashboardpro/model/monedero/gasto_recarga_mes_model.dart';
import 'package:dashboardpro/model/monedero/gasto_mes_model.dart';

class PasajeroWalletModel {
  final int idPasajero;
  final int idUsuario;
  final String correoUsuario;
  final String nombreCompleto;
  final String? nombreTipoPasajero;
  final String monederos;
  final double saldoTotal;
  final double? ultimaRecarga;
  final DateTime? fechaUltimaRecarga;
  final double? totalDebitosUltimoMes;
  final double? ultimoDebito;
  final DateTime? fechaUltimoDebito;
  final String? customerIdNetPay; // ID del cliente en NetPay
  final List<GastoRecargaMesModel> gastosYRecargasPorMes;
  final List<GastoMesModel> gastosPorMes;

  PasajeroWalletModel({
    required this.idPasajero,
    required this.idUsuario,
    required this.correoUsuario,
    required this.nombreCompleto,
    this.nombreTipoPasajero,
    required this.monederos,
    required this.saldoTotal,
    this.ultimaRecarga,
    this.fechaUltimaRecarga,
    this.totalDebitosUltimoMes,
    this.ultimoDebito,
    this.fechaUltimoDebito,
    this.customerIdNetPay,
    required this.gastosYRecargasPorMes,
    required this.gastosPorMes,
  });

  factory PasajeroWalletModel.fromJson(Map<String, dynamic> json) {
    return PasajeroWalletModel(
      idPasajero: json['idPasajero'] as int? ?? 0,
      idUsuario: json['idUsuario'] as int? ?? 0,
      correoUsuario: json['CorreoUsuario']?.toString() ?? '',
      nombreCompleto: json['NombreCompleto']?.toString() ?? '',
      nombreTipoPasajero: json['NombreTipoPasajero']?.toString(),
      monederos: json['Monederos']?.toString() ?? '',
      saldoTotal: (json['SaldoTotal'] as num?)?.toDouble() ?? 0.0,
      ultimaRecarga: json['UltimaRecarga'] != null
          ? (json['UltimaRecarga'] as num).toDouble()
          : null,
      fechaUltimaRecarga: json['FechaUltimaRecarga'] != null
          ? DateTime.tryParse(json['FechaUltimaRecarga'].toString())
          : null,
      totalDebitosUltimoMes: json['TotalDebitosUltimoMes'] != null
          ? (json['TotalDebitosUltimoMes'] as num).toDouble()
          : null,
      ultimoDebito: json['UltimoDebito'] != null
          ? (json['UltimoDebito'] as num).toDouble()
          : null,
      fechaUltimoDebito: json['FechaUltimoDebito'] != null
          ? DateTime.tryParse(json['FechaUltimoDebito'].toString())
          : null,
      customerIdNetPay: json['customerIdNetPay']?.toString(),
      gastosYRecargasPorMes: json['gastosYRecargasPorMes'] != null
          ? (json['gastosYRecargasPorMes'] as List<dynamic>)
              .map((item) => GastoRecargaMesModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      gastosPorMes: json['gastosPorMes'] != null
          ? (json['gastosPorMes'] as List<dynamic>)
              .map((item) => GastoMesModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPasajero': idPasajero,
      'idUsuario': idUsuario,
      'CorreoUsuario': correoUsuario,
      'NombreCompleto': nombreCompleto,
      'NombreTipoPasajero': nombreTipoPasajero,
      'Monederos': monederos,
      'SaldoTotal': saldoTotal,
      'UltimaRecarga': ultimaRecarga,
      'FechaUltimaRecarga': fechaUltimaRecarga?.toIso8601String(),
      'TotalDebitosUltimoMes': totalDebitosUltimoMes,
      'UltimoDebito': ultimoDebito,
      'FechaUltimoDebito': fechaUltimoDebito?.toIso8601String(),
      'customerIdNetPay': customerIdNetPay,
      'gastosYRecargasPorMes': gastosYRecargasPorMes.map((item) => item.toJson()).toList(),
      'gastosPorMes': gastosPorMes.map((item) => item.toJson()).toList(),
    };
  }

  /// Formatea el número de monederos para mostrar en la tarjeta
  /// Si viene "MON-001-0B", devuelve "**** **** **** 0B0B" (últimos caracteres)
  String get monederosFormateado {
    if (monederos.isEmpty) return '**** **** **** ****';
    
    // Extraer los últimos caracteres del número de serie
    final partes = monederos.split('-');
    if (partes.isEmpty) return '**** **** **** ****';
    
    final ultimaParte = partes.last;
    if (ultimaParte.length >= 2) {
      final ultimosDos = ultimaParte.substring(ultimaParte.length - 2);
      return '**** **** **** $ultimosDos';
    }
    
    // Si no se puede extraer, usar los últimos 4 caracteres del string completo
    if (monederos.length >= 4) {
      final ultimos4 = monederos.substring(monederos.length - 4);
      return '**** **** **** $ultimos4';
    }
    
    return '**** **** **** ****';
  }

  /// Formatea el saldo total con formato de moneda
  String get saldoTotalFormateado {
    return '\$${saldoTotal.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  /// Formatea la última recarga con formato de moneda
  String get ultimaRecargaFormateada {
    if (ultimaRecarga == null) return '--';
    return '\$${ultimaRecarga!.toStringAsFixed(2)}';
  }

  /// Formatea el total de débitos del último mes
  String get totalDebitosFormateado {
    if (totalDebitosUltimoMes == null) return '--';
    return '\$${totalDebitosUltimoMes!.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}

