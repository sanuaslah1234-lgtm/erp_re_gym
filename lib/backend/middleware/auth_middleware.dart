import 'package:shelf/shelf.dart';
import 'package:erp_software/core/constants/app_constants.dart';
import 'package:erp_software/backend/utils/response_utils.dart';
import 'package:erp_software/backend/services/jwt_service.dart';

/// Helper to check if a user payload satisfies a specific permission
bool can(JwtPayload? user, String permission) {
  if (user == null) return false;
  if (user.isSuperAdmin) return true;
  return user.can(permission);
}

/// Helper to get the authenticated user from Request context
JwtPayload? getAuthenticatedUser(Request request) {
  final user = request.context['user'];
  if (user is JwtPayload) return user;
  return null;
}

/// Standard Authentication & Role/Permission Middleware
Middleware authMiddleware({
  List<String> allowedRoles = const [],
  List<String> requiredPermissions = const [],
}) {
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

      // Check Allowed Roles
      if (allowedRoles.isNotEmpty && !payload.isSuperAdmin) {
        final normalizedAllowed = allowedRoles.map((r) => r.toUpperCase().trim()).toList();
        final userRole = payload.role.toUpperCase().trim();
        if (!normalizedAllowed.contains(userRole)) {
          return ResponseUtils.error(
            message: 'Forbidden: Role "$userRole" is not permitted to access this resource',
            statusCode: 403,
          );
        }
      }

      // Check Required Permissions
      if (requiredPermissions.isNotEmpty && !payload.isSuperAdmin) {
        final hasRequired = requiredPermissions.any((perm) => payload.can(perm));
        if (!hasRequired) {
          return ResponseUtils.error(
            message: 'Forbidden: Insufficient permissions (requires: ${requiredPermissions.join(", ")})',
            statusCode: 403,
          );
        }
      }

      final updatedRequest = request.change(context: {
        'user': payload,
        'userId': payload.userId,
      });

      return await innerHandler(updatedRequest);
    };
  };
}

/// Guard requiring a single specific permission (e.g. 'gym.members.manage')
Middleware requirePermission(String permission) {
  return authMiddleware(requiredPermissions: [permission]);
}

/// Guard requiring at least one of the provided permissions
Middleware requireAnyPermission(List<String> permissions) {
  return authMiddleware(requiredPermissions: permissions);
}

/// Guard requiring a specific role (e.g. AppRoles.superAdmin)
Middleware requireRole(String role) {
  return authMiddleware(allowedRoles: [role]);
}

/// Middleware that parses JWT token if present in headers, but allows unauthenticated requests
Middleware optionalAuthMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers[AppConstants.authHeader];
      if (authHeader != null && authHeader.startsWith(AppConstants.bearerPrefix)) {
        final token = authHeader.substring(AppConstants.bearerPrefix.length).trim();
        final payload = JwtService.verifyToken(token);
        if (payload != null) {
          final updatedRequest = request.change(context: {
            'user': payload,
            'userId': payload.userId,
          });
          return await innerHandler(updatedRequest);
        }
      }
      return await innerHandler(request);
    };
  };
}

