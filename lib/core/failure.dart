class Failure {
  final String message;
  final StackTrace stackTrace;
  final bool showError;

  Failure({
    required this.message,
    required this.stackTrace,
    this.showError = true,
  });
}
