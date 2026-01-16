import 'package:dashboardpro/model/monedero/qr_wallet_model.dart';

class QrWalletResponse {
  final String status;
  final String message;
  final QrWalletModel data;

  QrWalletResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QrWalletResponse.fromJson(Map<String, dynamic> json) {
    return QrWalletResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? QrWalletModel.fromJson(json['data'] as Map<String, dynamic>)
          : throw Exception('El campo "data" es requerido en la respuesta'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}
