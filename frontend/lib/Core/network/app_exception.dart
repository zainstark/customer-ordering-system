class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' (statusCode: $statusCode)';
    return 'AppException: $message$code';
  }
}
