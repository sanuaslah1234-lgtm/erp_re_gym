import 'package:erp_software/backend/models/user_model.dart';
import 'package:erp_software/core/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class AuthRepository {
  final PostgresService db;

  AuthRepository(this.db);

  Future<UserModel?> findUserByEmail(String email) async {
    final result = await db.connection.execute(
      Sql.named('''
        SELECT id, email, password_hash, role, is_active, last_login_at, created_at, updated_at
        FROM users
        WHERE LOWER(email) = LOWER(@email)
        LIMIT 1
      '''),
      parameters: {'email': email},
    );

    if (result.isEmpty) return null;
    final row = result.first;

    return UserModel(
      id: row[0] as int,
      email: row[1] as String,
      passwordHash: row[2] as String,
      role: row[3] as String,
      isActive: row[4] as bool,
      lastLoginAt: row[5] != null ? DateTime.tryParse(row[5].toString()) : null,
      createdAt: row[6] != null ? DateTime.tryParse(row[6].toString()) : null,
      updatedAt: row[7] != null ? DateTime.tryParse(row[7].toString()) : null,
    );
  }

  Future<UserModel?> findUserByIdentifier(String identifier) async {
    final result = await db.connection.execute(
      Sql.named('''
        SELECT u.id, u.email, u.password_hash, u.role, u.is_active, u.last_login_at, u.created_at, u.updated_at
        FROM users u
        LEFT JOIN employees e ON u.id = e.user_id
        WHERE LOWER(u.email) = LOWER(@identifier) OR LOWER(e.employee_id) = LOWER(@identifier)
        LIMIT 1
      '''),
      parameters: {'identifier': identifier},
    );

    if (result.isEmpty) return null;
    final row = result.first;

    return UserModel(
      id: row[0] as int,
      email: row[1] as String,
      passwordHash: row[2] as String,
      role: row[3] as String,
      isActive: row[4] as bool,
      lastLoginAt: row[5] != null ? DateTime.tryParse(row[5].toString()) : null,
      createdAt: row[6] != null ? DateTime.tryParse(row[6].toString()) : null,
      updatedAt: row[7] != null ? DateTime.tryParse(row[7].toString()) : null,
    );
  }

  Future<UserModel?> findUserById(int id) async {
    final result = await db.connection.execute(
      Sql.named('''
        SELECT id, email, password_hash, role, is_active, last_login_at, created_at, updated_at
        FROM users
        WHERE id = @id
        LIMIT 1
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    final row = result.first;

    return UserModel(
      id: row[0] as int,
      email: row[1] as String,
      passwordHash: row[2] as String,
      role: row[3] as String,
      isActive: row[4] as bool,
      lastLoginAt: row[5] != null ? DateTime.tryParse(row[5].toString()) : null,
      createdAt: row[6] != null ? DateTime.tryParse(row[6].toString()) : null,
      updatedAt: row[7] != null ? DateTime.tryParse(row[7].toString()) : null,
    );
  }

  Future<void> updateLastLogin(int userId) async {
    await db.connection.execute(
      Sql.named('''
        UPDATE users
        SET last_login_at = CURRENT_TIMESTAMP
        WHERE id = @id
      '''),
      parameters: {'id': userId},
    );
  }

  Future<void> updateUserRole(int userId, String newRole) async {
    await db.connection.execute(
      Sql.named('''
        UPDATE users
        SET role = @role, updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
      '''),
      parameters: {
        'id': userId,
        'role': newRole,
      },
    );
  }

  Future<void> toggleUserActiveStatus(int userId, bool isActive) async {
    await db.connection.execute(
      Sql.named('''
        UPDATE users
        SET is_active = @is_active, updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
      '''),
      parameters: {
        'id': userId,
        'is_active': isActive,
      },
    );
  }

  Future<UserModel> createUser({
    required String email,
    required String passwordHash,
    String role = 'employee',
  }) async {
    final result = await db.connection.execute(
      Sql.named('''
        INSERT INTO users (email, password_hash, role, is_active)
        VALUES (@email, @password_hash, @role, true)
        RETURNING id, email, password_hash, role, is_active, last_login_at, created_at, updated_at
      '''),
      parameters: {
        'email': email,
        'password_hash': passwordHash,
        'role': role,
      },
    );
    final row = result.first;
    return UserModel(
      id: row[0] as int,
      email: row[1] as String,
      passwordHash: row[2] as String,
      role: row[3] as String,
      isActive: row[4] as bool,
      lastLoginAt: row[5] != null ? DateTime.tryParse(row[5].toString()) : null,
      createdAt: row[6] != null ? DateTime.tryParse(row[6].toString()) : null,
      updatedAt: row[7] != null ? DateTime.tryParse(row[7].toString()) : null,
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
