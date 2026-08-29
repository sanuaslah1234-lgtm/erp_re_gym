import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database/postgres_service.dart';
import 'middleware/cors_middleware.dart';
import 'utils/response_utils.dart';
import 'routes/app_router.dart';

class BackendServer {
  final PostgresService postgresService;
  late final Router router;

  BackendServer(this.postgresService) {
    router = Router();
  }

  Handler get handler {
    return const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addMiddleware(_errorHandler())
        .addHandler(router.call);
  }

  void setupRoutes(AppRouter appRouter) {
    // Mount the AppRouter under /api
    router.mount('/api', appRouter.router.call);

    // Global fallback for any unhandled routes
    router.all('/<ignored|.*>', (Request request) {
      return ResponseUtils.notFound(message: 'Route not found: ${request.url}');
    });
  }

  Middleware _errorHandler() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          return await innerHandler(request);
        } catch (e, stackTrace) {
          print('--- Backend Error ---');
          print('Error: $e');
          print('Stack: $stackTrace');
          return ResponseUtils.error(
            message: 'Internal Server Error',
            statusCode: 500,
            error: e.toString(),
          );
        }
      };
    };
  }
}
