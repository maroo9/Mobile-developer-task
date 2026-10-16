
import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthenticationException extends AppException {
  const AuthenticationException([
    super.message = 'Authentication failed.',
  ]);
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network connection failed.',
  ]);
}

class OdooApiException extends AppException {
  const OdooApiException([
    super.message = 'Odoo request failed.',
  ]);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error occurred.',
  ]);
}

class ParsingException extends AppException {
  const ParsingException([
    super.message = 'Invalid server response.',
  ]);
}

class UnexpectedException extends AppException {
  const UnexpectedException([
    super.message = 'An unexpected error occurred.',
  ]);
}

class ErrorHandling {
  ErrorHandling._();

  static AppException handle(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.receiveTimeout:
          return const NetworkException(
            'The request timed out. Please try again.',
          );

        case DioErrorType.response:
          final statusCode = error.response?.statusCode;

          if (statusCode == 401 || statusCode == 403) {
            return const AuthenticationException(
              'You are not authorized to perform this operation.',
            );
          }

          if (statusCode != null && statusCode >= 500) {
            return const ServerException(
              'The server encountered an error.',
            );
          }

          return ServerException(
            'The request failed with HTTP status $statusCode.',
          );

        case DioErrorType.cancel:
          return const NetworkException('The request was cancelled.');

        case DioErrorType.other:
          return const NetworkException(
            'Could not connect. Check your internet connection.',
          );
      }
    }

    return const UnexpectedException();
  }
}
