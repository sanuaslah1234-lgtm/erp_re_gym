abstract class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException([this.message = 'Something went wrong', this.prefix]);

  @override
  String toString() {
    return prefix != null ? '$prefix: $message' : message;
  }
}

class ApiException extends AppException {
  final int statusCode;
  ApiException(String message, {this.statusCode = 500}) : super(message, 'API Error');

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication failed']) : super(message, 'Auth Error');
}

class ValidationException extends AppException {
  ValidationException([String message = 'Validation failed']) : super(message, 'Validation Error');
}

class DatabaseException extends AppException {
  DatabaseException([String message = 'Database operation failed']) : super(message, 'Database Error');
}

