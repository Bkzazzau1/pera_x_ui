class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppException({required this.message, this.code, this.cause});

  @override
  String toString() {
    if (code == null) return message;
    return '[$code] $message';
  }
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.cause});
}

class ApiException extends AppException {
  final int? statusCode;

  const ApiException({
    required super.message,
    this.statusCode,
    super.code,
    super.cause,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized request.',
    super.code,
    super.cause,
  });
}
