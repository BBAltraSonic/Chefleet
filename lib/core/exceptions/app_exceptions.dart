abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);

  @override
  String toString() => 'Network Error: $message';
}

class AuthException extends AppException {
  const AuthException(super.message);

  @override
  String toString() => 'Authentication Error: $message';
}

class ValidationException extends AppException {
  const ValidationException(super.message);

  @override
  String toString() => 'Validation Error: $message';
}

class ServerException extends AppException {
  const ServerException(super.message);

  @override
  String toString() => 'Server Error: $message';
}

class CacheException extends AppException {
  const CacheException(super.message);

  @override
  String toString() => 'Cache Error: $message';
}

class UnknownException extends AppException {
  const UnknownException(super.message);

  @override
  String toString() => 'Unknown Error: $message';
}