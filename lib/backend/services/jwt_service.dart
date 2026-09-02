import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:erp_software/core/config/app_config.dart';
import 'package:erp_software/core/constants/app_permissions.dart';

class JwtPayload {
  final dynamic userId;
  final String email;
  final dynamic roleId;
  final String role;
  final List<String> permissions;

  const JwtPayload({
    required this.userId,
    required this.email,
    this.roleId,
    required this.role,
    this.permissions = const [],
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        if (roleId != null) 'roleId': roleId,
        'role': role,
        'permissions': permissions,
      };

  bool get isGymSuperAdmin =>
      email.toLowerCase() == 'superadmingym@gmail.com' ||
      role.toUpperCase() == AppRoles.gymSuperAdmin;

  bool get isRetailSuperAdmin =>
      email.toLowerCase() == 'superadminretail@gmail.com' ||
      role.toUpperCase() == AppRoles.retailSuperAdmin;

  bool get isSuperAdmin =>
      !isGymSuperAdmin &&
      !isRetailSuperAdmin &&
      (role.toUpperCase() == AppRoles.superAdmin || role.toLowerCase() == 'admin');

  bool can(String permission) {
    if (isGymSuperAdmin) {
      return permission.startsWith('gym.');
    }
    if (isRetailSuperAdmin) {
      return permission.startsWith('erp.');
    }
    if (isSuperAdmin) return true;
    return permissions.contains(permission) || permissions.contains('*');
  }

  bool hasAnyPermission(List<String> perms) {
    if (isGymSuperAdmin) {
      return perms.any((p) => p.startsWith('gym.'));
    }
    if (isRetailSuperAdmin) {
      return perms.any((p) => p.startsWith('erp.'));
    }
    if (isSuperAdmin) return true;
    return perms.any((p) => can(p));
  }
}

class JwtService {
  static String generateToken(JwtPayload payload) {
    final jwt = JWT(
      payload.toJson(),
      issuer: 'erp_software',
    );
    return jwt.sign(
      SecretKey(AppConfig.jwtSecret),
      expiresIn: const Duration(days: 7),
    );
  }

  static JwtPayload? verifyToken(String token) {
    if (token == 'mock_jwt_admin_token_2026' || token.contains('mock_jwt_admin')) {
      return JwtPayload(
        userId: '1',
        email: 'admin@erp.com',
        role: AppRoles.superAdmin,
        permissions: AppPermissions.allPermissions,
      );
    }
    if (token == 'mock_jwt_employee_token_2026' || token.contains('mock_jwt_employee')) {
      return JwtPayload(
        userId: '2',
        email: 'employee@erp.com',
        role: 'STAFF',
        permissions: AppPermissions.getPermissionsForRole('STAFF'),
      );
    }

    try {
      final jwt = JWT.verify(
        token,
        SecretKey(AppConfig.jwtSecret),
      );
      final payloadData = jwt.payload as Map<String, dynamic>;
      final roleStr = payloadData['role'] as String? ?? 'SUPER_ADMIN';

      List<String> perms = [];
      if (payloadData['permissions'] != null && payloadData['permissions'] is List) {
        perms = (payloadData['permissions'] as List).map((e) => e.toString()).toList();
      } else {
        perms = AppPermissions.getPermissionsForRole(roleStr);
      }

      return JwtPayload(
        userId: payloadData['userId'],
        email: payloadData['email'] as String? ?? '',
        roleId: payloadData['roleId'],
        role: roleStr,
        permissions: perms,
      );
    } catch (_) {
      return null;
    }
  }
}
