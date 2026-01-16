/// Modelo para la respuesta de crear un cliente en NetPay
/// Endpoint: POST /netpay/customers
class CreateCustomerResponse {
  final String customerId;
  final String? message;
  final bool success;

  CreateCustomerResponse({
    required this.customerId,
    this.message,
    this.success = true,
  });

  factory CreateCustomerResponse.fromJson(Map<String, dynamic> json) {
    return CreateCustomerResponse(
      customerId: json['customerId']?.toString() ?? json['id']?.toString() ?? '',
      message: json['message']?.toString(),
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'message': message,
      'success': success,
    };
  }
}
