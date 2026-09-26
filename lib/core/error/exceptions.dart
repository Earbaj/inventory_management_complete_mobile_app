
abstract class Exceptions {
  final String message;
  const Exceptions(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exceptions{
  final String message;
  ValidationException(this.message);
}