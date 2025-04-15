class TemplateApplicationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  final Map<String, List<String>>? nonFieldErrors;
  final Map<String, List<String>>? generalFieldErrors;

  TemplateApplicationException({
    required this.message,
    this.fieldErrors,
    this.nonFieldErrors,
    this.generalFieldErrors,
  });

  @override
  String toString() {
    return 'TemplateApplicationException: $message';
  }
}
