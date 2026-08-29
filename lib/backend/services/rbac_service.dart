import 'package:postgres/postgres.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/constants/app_permissions.dart';

class RbacService {
  final PostgresService postgresService;

  RbacService(this.postgresService);

  Connection get _conn => postgresService.connection;

  /// Fetch effective permissions for a user by user ID.
  /// If database has bindings, returns them; otherwise falls back to static mapping.
  Future<List<String>> getPermissionsForUser(dynamic userId) async {
    try {
      final res = await _conn.execute(
        Sql.named('''
          SELECT DISTINCT p.name
          FROM users u
          JOIN roles r ON (u.role_id = r.id OR LOWER(u.role) = LOWER(r.name))
          JOIN role_permissions rp ON r.id = rp.role_id
          JOIN permissions p ON rp.permission_id = p.id
          WHERE u.id = @userId OR u.id::text = @userIdStr
        '''),
        parameters: {
          'userId': userId,
          'userIdStr': userId.toString(),
        },
      );

      if (res.isNotEmpty) {
        return res.map((row) => row[0].toString()).toList();
      }

      // Fallback: look up role string on user
      final userRes = await _conn.execute(
        Sql.named('SELECT role FROM users WHERE u.id = @userId OR u.id::text = @userIdStr LIMIT 1'),
        parameters: {
          'userId': userId,
          'userIdStr': userId.toString(),
        },
      );

      if (userRes.isNotEmpty) {
        final role = userRes.first[0]?.toString() ?? '';
        return AppPermissions.getPermissionsForRole(role);
      }
    } catch (_) {}

    return [];
  }

  /// Fetch effective permissions for a role name
  Future<List<String>> getPermissionsForRoleName(String roleName) async {
    try {
      final res = await _conn.execute(
        Sql.named('''
          SELECT DISTINCT p.name
          FROM roles r
          JOIN role_permissions rp ON r.id = rp.role_id
          JOIN permissions p ON rp.permission_id = p.id
          WHERE LOWER(r.name) = LOWER(@roleName)
        '''),
        parameters: {'roleName': roleName},
      );

      if (res.isNotEmpty) {
        return res.map((row) => row[0].toString()).toList();
      }
    } catch (_) {}

    return AppPermissions.getPermissionsForRole(roleName);
  }

  /// Check if user has a specific permission
  Future<bool> userHasPermission(dynamic userId, String permission) async {
    final perms = await getPermissionsForUser(userId);
    return perms.contains(permission) || perms.contains('*');
  }

  /// Get all roles with their assigned permissions
  Future<List<Map<String, dynamic>>> getAllRoles() async {
    final res = await _conn.execute(Sql.named('SELECT * FROM roles ORDER BY name ASC'));
    final List<Map<String, dynamic>> roles = [];

    for (final row in res) {
      final map = row.toColumnMap();
      final roleId = map['id'].toString();

      final permRes = await _conn.execute(
        Sql.named('''
          SELECT p.name, p.module, p.description
          FROM role_permissions rp
          JOIN permissions p ON rp.permission_id = p.id
          WHERE rp.role_id = @roleId
          ORDER BY p.name ASC
        '''),
        parameters: {'roleId': roleId},
      );

      map['permissions'] = permRes.map((p) => p[0].toString()).toList();
      roles.add(map);
    }

    return roles;
  }

  /// Get all registered permissions
  Future<List<Map<String, dynamic>>> getAllPermissions() async {
    final res = await _conn.execute(Sql.named('SELECT * FROM permissions ORDER BY module ASC, name ASC'));
    return res.map((r) => r.toColumnMap()).toList();
  }
}
