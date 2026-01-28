import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

class QrWalletModel {
  final String qrCode; // Base64 string con prefijo data:image/png;base64,
  final double saldo;
  final String numeroSerie;
  final String idQR;
  final int? numeroPasajes; // * UPDATE: Número de pasajes incluido en la respuesta

  QrWalletModel({
    required this.qrCode,
    required this.saldo,
    required this.numeroSerie,
    required this.idQR,
    this.numeroPasajes, // * UPDATE: Campo opcional para mantener compatibilidad
  });

  factory QrWalletModel.fromJson(Map<String, dynamic> json) {
    return QrWalletModel(
      qrCode: json['qrCode']?.toString() ?? '',
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      numeroSerie: json['numeroSerie']?.toString() ?? '',
      idQR: json['idQR']?.toString() ?? '',
      numeroPasajes: json['numeroPasajes'] != null ? (json['numeroPasajes'] as num).toInt() : null, // * UPDATE: Parsear numeroPasajes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qrCode': qrCode,
      'saldo': saldo,
      'numeroSerie': numeroSerie,
      'idQR': idQR,
      if (numeroPasajes != null) 'numeroPasajes': numeroPasajes, // * UPDATE: Incluir numeroPasajes si existe
    };
  }

  /// Extrae el Base64 puro del qrCode (elimina el prefijo data:image/png;base64,)
  String get base64Puro {
    if (qrCode.isEmpty) return '';
    
    // Si tiene el prefijo data:image/png;base64,, lo removemos
    if (qrCode.startsWith('data:image')) {
      final parts = qrCode.split(',');
      return parts.length > 1 ? parts[1] : qrCode;
    }
    
    return qrCode;
  }

  /// Convierte el Base64 a Uint8List para mostrar la imagen
  Uint8List? get qrImageBytes {
    try {
      final base64 = base64Puro;
      if (base64.isEmpty) return null;
      return base64Decode(base64);
    } catch (e) {
      return null;
    }
  }

  /// Verifica si el QR es válido
  bool get esValido => qrCode.isNotEmpty && base64Puro.isNotEmpty && qrImageBytes != null;

  /// Formatea el saldo como moneda
  String get saldoFormateado {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(saldo);
  }
}
