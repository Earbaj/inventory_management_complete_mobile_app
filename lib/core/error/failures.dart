/// Base Failure Class for Clean Architecture Error Handling
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Failure representing server-side HTTP errors (e.g. 500 Internal Server Error).
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Failure representing network connectivity or timeout issues.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connectivity issue. Please try again.']);
}

/// Failure representing unauthorized authentication (e.g. 401 Invalid or Expired Token).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized session. Please login again.']);
}

/// Failure representing local cache or storage read/write failures.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure.']);
}
