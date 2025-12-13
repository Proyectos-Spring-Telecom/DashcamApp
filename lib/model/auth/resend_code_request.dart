class ResendCodeRequest {
  final String userName;

  ResendCodeRequest({
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
    };
  }
}

