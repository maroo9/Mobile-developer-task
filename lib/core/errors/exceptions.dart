
/// Base exception for application-specific errors.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Authentication or session-related errors.
class AuthenticationException extends AppException {
  const AuthenticationException([
    super.message = 'Authentication failed.',
  ]);
}

/// Network connectivity and timeout errors.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network connection failed.',
  ]);
}

/// Errors returned by Odoo's API.
class OdooApiException extends AppException {
  const OdooApiException([
    super.message = 'Odoo API request failed.',
  ]);
}

/// Server-side errors.
class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error occurred.',
  ]);
}

/// Invalid or unexpected response data.
class ParsingException extends AppException {
  const ParsingException([
    super.message = 'Invalid server response.',
  ]);
}

/// Unexpected errors that do not match another category.
class UnexpectedException extends AppException {
  const UnexpectedException([
    super.message = 'An unexpected error occurred.',
  ]);
}
