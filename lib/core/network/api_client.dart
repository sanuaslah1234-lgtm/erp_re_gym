import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exception.dart';
/// Thin wrapper around package:http that:
///  - always sends/expects JSON
///  - unwraps your backend's { success, message, data } envelope
///  - throws ApiException with the server message on failure
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers);
    return _handle(response);
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> delete(String url) async {
    final response = await _client.delete(Uri.parse(url), headers: _headers);
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Invalid response from server',
        statusCode: response.statusCode,
      );
    }

    final success = decoded['success'] == true;
    final message = decoded['message']?.toString() ?? 'Something went wrong';

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return decoded['data'];
    }

    throw ApiException(message, statusCode: response.statusCode);
  }
}