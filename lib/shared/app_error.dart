
class ApplicationError extends Error {
  final String message;

  ApplicationError({required this.message});

  @override
  String toString() => 'ApplicationError(message: $message)';
}