/// Modelo para el request de crear un cliente en NetPay
/// Endpoint: POST /netpay/customers
class CreateCustomerRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String token;
  final int idPasajero;

  CreateCustomerRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.token,
    required this.idPasajero,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'token': token,
      'idPasajero': idPasajero,
    };
  }
}
