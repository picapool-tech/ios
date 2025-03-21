class Failure {
  final String message;
  final StackTrace stackTrace;
  final bool showError;
  final int? errorCode;
  final Object? originalError;

  Failure({
    required this.message,
    required this.stackTrace,
    this.showError = true,
    this.errorCode,
    this.originalError,
  });
}
