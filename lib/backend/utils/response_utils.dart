import 'dart:convert';
import 'package:shelf/shelf.dart';

class ResponseUtils {
  static Response success({
    String message = 'Success',
    dynamic data,
    int statusCode = 200,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': true,
        'message': message,
        'data': data ?? {},
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response error({
    String message = 'An error occurred',
    int statusCode = 400,
    dynamic error,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'message': message,
        if (error != null) 'error': error.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response unauthorized({String message = 'Unauthorized'}) {
    return error(message: message, statusCode: 401);
  }

  static Response badRequest({String message = 'Bad Request'}) {
    return error(message: message, statusCode: 400);
  }

  static Response notFound({String message = 'Resource not found'}) {
    return error(message: message, statusCode: 404);
  }
}
