class ApiError implements Exception {
  ApiError({
    required this.message,
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Object? details;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' (status: $statusCode)';
    return 'ApiError$code: $message';
  }
}
