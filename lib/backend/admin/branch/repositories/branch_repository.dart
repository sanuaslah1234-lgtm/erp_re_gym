import 'package:postgres/postgres.dart';

class BranchRepository {
  final Connection connection;

  BranchRepository(this.connection);

  // ============================================================
  // CREATE BRANCH
  // ============================================================

  Future<Map<String, dynamic>> createBranch(
    Map<String, dynamic> data,
  ) async {
    final result = await connection.execute(
      Sql.named('''
        INSERT INTO branches (
          code,
          name,
          address,
          city,
          state,
          phone,
          email,
          is_active
        )
        VALUES (
          @code,
          @name,
          @address,
          @city,
          @state,
          @phone,
          @email,
          @is_active
        )
        RETURNING
          id,
          code,
          name,
          address,
          city,
          state,
          phone,
          email,
          is_active,
          created_at,
          updated_at
      '''),
      parameters: {
        'code': data['code'],
        'name': data['name'],
        'address': data['address'],
        'city': data['city'],
        'state': data['state'],
        'phone': data['phone'],
        'email': data['email'],
        'is_active': data['is_active'] ?? true,
      },
    );

    final row = result.first;

    return _mapBranch(row);
  }

  // ============================================================
  // GET ALL BRANCHES
  // ============================================================

  Future<List<Map<String, dynamic>>> getBranches() async {
    final result = await connection.execute('''
      SELECT
        id,
        code,
        name,
        address,
        city,
        state,
        phone,
        email,
        is_active,
        created_at,
        updated_at
      FROM branches
      ORDER BY id DESC
    ''');

    return result.map(_mapBranch).toList();
  }

  // ============================================================
  // GET BRANCH BY ID
  // ============================================================

  Future<Map<String, dynamic>?> getBranchById(int id) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT
          id,
          code,
          name,
          address,
          city,
          state,
          phone,
          email,
          is_active,
          created_at,
          updated_at
        FROM branches
        WHERE id = @id
        LIMIT 1
      '''),
      parameters: {
        'id': id,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return _mapBranch(result.first);
  }

  // ============================================================
  // UPDATE BRANCH
  // ============================================================

  Future<Map<String, dynamic>?> updateBranch(
    int id,
    Map<String, dynamic> data,
  ) async {
    final result = await connection.execute(
      Sql.named('''
        UPDATE branches
        SET
          code = @code,
          name = @name,
          address = @address,
          city = @city,
          state = @state,
          phone = @phone,
          email = @email,
          is_active = @is_active,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING
          id,
          code,
          name,
          address,
          city,
          state,
          phone,
          email,
          is_active,
          created_at,
          updated_at
      '''),
      parameters: {
        'id': id,
        'code': data['code'],
        'name': data['name'],
        'address': data['address'],
        'city': data['city'],
        'state': data['state'],
        'phone': data['phone'],
        'email': data['email'],
        'is_active': data['is_active'] ?? true,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return _mapBranch(result.first);
  }

  // ============================================================
  // DELETE BRANCH
  // ============================================================

  Future<bool> deleteBranch(int id) async {
    final result = await connection.execute(
      Sql.named('''
        DELETE FROM branches
        WHERE id = @id
      '''),
      parameters: {
        'id': id,
      },
    );

    return result.affectedRows > 0;
  }

  // ============================================================
  // MAP DATABASE ROW
  // ============================================================

  Map<String, dynamic> _mapBranch(ResultRow row) {
    return {
      'id': row[0],
      'code': row[1],
      'name': row[2],
      'address': row[3],
      'city': row[4],
      'state': row[5],
      'phone': row[6],
      'email': row[7],
      'is_active': row[8],
      'created_at': row[9]?.toString(),
      'updated_at': row[10]?.toString(),
    };
  }
}