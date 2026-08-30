import 'dart:convert';

import 'package:shelf/shelf.dart';

class ResponseUtils {
  /// Success response
  static Response success({
    String message = 'Success',
    dynamic data,
    int statusCode = 200,
  }) {
    final responseData = {
      'success': true,
      'message': message,
      'data': _makeJsonEncodable(data ?? {}),
    };

    return Response(
      statusCode,
      body: jsonEncode(responseData),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
  }

  /// Error response
  static Response error({
    String message = 'An error occurred',
    int statusCode = 400,
    dynamic error,
  }) {
    final responseData = {
      'success': false,
      'message': message,
      if (error != null) 'error': _makeJsonEncodable(error),
    };

    return Response(
      statusCode,
      body: jsonEncode(responseData),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
  }

  /// Unauthorized response
  static Response unauthorized({
    String message = 'Unauthorized',
  }) {
    return error(
      message: message,
      statusCode: 401,
    );
  }

  /// Bad request response
  static Response badRequest({
    String message = 'Bad Request',
  }) {
    return error(
      message: message,
      statusCode: 400,
    );
  }

  /// Not found response
  static Response notFound({
    String message = 'Resource not found',
  }) {
    return error(
      message: message,
      statusCode: 404,
    );
  }

  /// Convert Dart/PostgreSQL objects into JSON-safe values.
  static dynamic _makeJsonEncodable(dynamic value) {
    if (value == null) {
      return null;
    }

    // Already JSON-safe
    if (value is String ||
        value is num ||
        value is bool) {
      return value;
    }

    // PostgreSQL TIMESTAMP / DATE values
    if (value is DateTime) {
      return value.toIso8601String();
    }

    // Lists
    if (value is List) {
      return value
          .map((item) => _makeJsonEncodable(item))
          .toList();
    }

    // Maps
    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(
          key.toString(),
          _makeJsonEncodable(mapValue),
        ),
      );
    }

    // Sets
    if (value is Set) {
      return value
          .map((item) => _makeJsonEncodable(item))
          .toList();
    }

    // Fallback for unsupported objects
    return value.toString();
  }
}