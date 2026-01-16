class ForgotPasswordRequest {
  final String userName;

  ForgotPasswordRequest({
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
    };
  }
}

