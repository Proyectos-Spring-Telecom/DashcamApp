class Result<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  const Result._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory Result.success(T data, {int? statusCode}) {
    return Result._(isSuccess: true, data: data, statusCode: statusCode);
  }

  factory Result.failure(String message, {int? statusCode}) {
    return Result._(isSuccess: false, errorMessage: message, statusCode: statusCode);
  }
}
