import 'package:shelf/shelf.dart';
import 'package:erp_software/core/constants/app_constants.dart';
import 'package:erp_software/backend/utils/response_utils.dart';
import 'package:erp_software/backend/services/jwt_service.dart';

Middleware authMiddleware({List<String> allowedRoles = const []}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers[AppConstants.authHeader];

      if (authHeader == null || !authHeader.startsWith(AppConstants.bearerPrefix)) {
        return ResponseUtils.error(
          message: 'Missing or invalid Authorization header',
          statusCode: 401,
        );
      }

      final token = authHeader.substring(AppConstants.bearerPrefix.length).trim();
      final payload = JwtService.verifyToken(token);

      if (payload == null) {
        return ResponseUtils.error(
          message: 'Invalid or expired JWT token',
          statusCode: 401,
        );
      }

      if (allowedRoles.isNotEmpty && !allowedRoles.contains(payload.role.toLowerCase())) {
        return ResponseUtils.error(
          message: 'Forbidden: Insufficient privileges for this role',
          statusCode: 403,
        );
      }

      final updatedRequest = request.change(context: {
        'user': payload,
      });

      return await innerHandler(updatedRequest);
    };
  };
}

