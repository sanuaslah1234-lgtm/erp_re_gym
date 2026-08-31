import 'package:erp_software/core/constants/app_permissions.dart';
import 'package:erp_software/core/models/user_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class AuthRepository {
  final PostgresService db;

  AuthRepository(this.db);

  UserModel _rowToUser(ResultRow row) {
    final roleStr = row[3]?.toString() ?? 'SUPER_ADMIN';
    final roleId = row.length > 10 ? row[10] : null;

    return UserModel(
      id: row[0],
      email: row[1]?.toString() ?? '',
      passwordHash: row[2]?.toString(),
      role: roleStr,
      isActive: row[4] == true,
      lastLoginAt: row[5] != null ? DateTime.tryParse(row[5].toString()) : null,
      createdAt: row[6] != null ? DateTime.tryParse(row[6].toString()) : null,
      updatedAt: row[7] != null ? DateTime.tryParse(row[7].toString()) : null,
      plainPassword: row.length > 8 ? row[8]?.toString() : null,
      employeeId: row.length > 9 ? row[9]?.toString() : null,
      roleId: roleId,
      permissions: AppPermissions.getPermissionsForRole(roleStr),
    );
  }

  Future<UserModel?> findUserByEmail(String email) async {
    final result = await db.connection.execute(
      Sql.named('''
        SELECT 
          u.id, 
          u.email, 
          u.password_hash, 
          COALESCE(r.name, u.role) AS role, 
          COALESCE(u.is_verified, true) AS is_active, 
          u.updated_at AS last_login_at, 
          u.created_at, 
          u.updated_at,
          u.plain_password,
          u.employee_id,
          u.role_id
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        WHERE LOWER(u.email) = LOWER(@email)
        LIMIT 1
      '''),
      parameters: {'email': email},
    );

    if (result.isEmpty) return null;
    return _rowToUser(result.first);
  }

  Future<UserModel?> findUserByIdentifier(String identifier) async {
    final result = await db.connection.execute(
      Sql.named('''
        SELECT 
          u.id, 
          u.email, 
          u.password_hash, 
          COALESCE(r.name, u.role) AS role, 
          COALESCE(u.is_verified, true) AS is_active, 
          u.updated_at AS last_login_at, 
          u.created_at, 
          u.updated_at,
          u.plain_password,
          u.employee_id,
          u.role_id
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        WHERE LOWER(u.email) = LOWER(@identifier) 
           OR LOWER(COALESCE(u.employee_id, '')) = LOWER(@identifier)
        LIMIT 1
      '''),
      parameters: {'identifier': identifier},
    );

    if (result.isEmpty) return null;
    return _rowToUser(result.first);
  }

  Future<UserModel?> findUserById(dynamic id) async {
    final result = await db.connection.execute(
      Sql.named('''
        SELECT 
          u.id, 
          u.email, 
          u.password_hash, 
          COALESCE(r.name, u.role) AS role, 
          COALESCE(u.is_verified, true) AS is_active, 
          u.updated_at AS last_login_at, 
          u.created_at, 
          u.updated_at,
          u.plain_password,
          u.employee_id,
          u.role_id
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        WHERE u.id = @id OR u.id::text = @idStr
        LIMIT 1
      '''),
      parameters: {'id': id, 'idStr': id.toString()},
    );

    if (result.isEmpty) return null;
    return _rowToUser(result.first);
  }

  Future<void> updateLastLogin(dynamic userId) async {
    try {
      await db.connection.execute(
        Sql.named('''
          UPDATE users
          SET updated_at = CURRENT_TIMESTAMP
          WHERE id = @id OR id::text = @idStr
        '''),
        parameters: {'id': userId, 'idStr': userId.toString()},
      );
    } catch (_) {}
  }

  Future<void> updateUserRole(dynamic userId, String newRole) async {
    await db.connection.execute(
      Sql.named('''
        UPDATE users
        SET role = @role,
            role_id = (SELECT id FROM roles WHERE LOWER(name) = LOWER(@role) LIMIT 1),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = @id OR id::text = @idStr
      '''),
      parameters: {
        'id': userId,
        'idStr': userId.toString(),
        'role': newRole,
      },
    );
  }

  Future<void> toggleUserActiveStatus(dynamic userId, bool isActive) async {
    await db.connection.execute(
      Sql.named('''
        UPDATE users
        SET is_verified = @is_active, updated_at = CURRENT_TIMESTAMP
        WHERE id = @id OR id::text = @idStr
      '''),
      parameters: {
        'id': userId,
        'idStr': userId.toString(),
        'is_active': isActive,
      },
    );
  }

  Future<UserModel> createUser({
    required String email,
    required String passwordHash,
    String role = 'SUPER_ADMIN',
    int? roleId,
    String? employeeId,
    String? plainPassword,
  }) async {
    final result = await db.connection.execute(
      Sql.named('''
        INSERT INTO users (email, password_hash, role, role_id, is_verified, employee_id, plain_password)
        VALUES (
          @email, 
          @password_hash, 
          @role, 
          COALESCE(@role_id, (SELECT id FROM roles WHERE LOWER(name) = LOWER(@role) LIMIT 1)), 
          true, 
          @employee_id, 
          @plain_password
        )
        RETURNING id, email, password_hash, role, is_verified, created_at, updated_at, plain_password, employee_id, role_id
      '''),
      parameters: {
        'email': email,
        'password_hash': passwordHash,
        'role': role,
        'role_id': roleId,
        'employee_id': employeeId,
        'plain_password': plainPassword,
      },
    );
    final row = result.first;
    final rStr = row[3]?.toString() ?? role;
    return UserModel(
      id: row[0],
      email: row[1]?.toString() ?? '',
      passwordHash: row[2]?.toString(),
      role: rStr,
      isActive: row[4] == true,
      createdAt: row[5] != null ? DateTime.tryParse(row[5].toString()) : null,
      updatedAt: row[6] != null ? DateTime.tryParse(row[6].toString()) : null,
      plainPassword: row[7]?.toString(),
      employeeId: row[8]?.toString(),
      roleId: row.length > 9 && row[9] != null ? int.tryParse(row[9].toString()) : null,
      permissions: AppPermissions.getPermissionsForRole(rStr),
    );
  }

  Future<void> updatePasswordByEmail(String email, String passwordHash) async {
    await db.connection.execute(
      Sql.named('''
        UPDATE users
        SET password_hash = @password_hash, updated_at = CURRENT_TIMESTAMP
        WHERE LOWER(email) = LOWER(@email)
      '''),
      parameters: {
        'email': email,
        'password_hash': passwordHash,
      },
    );
  }
}
