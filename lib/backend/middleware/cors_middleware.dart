import 'package:shelf/shelf.dart';

/// Allows browser-based clients (Flutter web running on a different port)
/// to call this API. Without this, Chrome silently blocks every request
/// with a CORS error and Flutter just sees a generic "failed" exception.
Middleware corsHeaders() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      // Browsers send an OPTIONS "preflight" request before the real one.
      // Answer it immediately with the allow-headers, don't pass to router.
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }

      final response = await innerHandler(request);
      return response.change(headers: headers);
    };
  };
}