import 'package:postgres/postgres.dart';

class ManagerRepository {
  final Connection connection;

  ManagerRepository(this.connection);

  static const _selectColumns = '''
    e.id, e.employee_id, e.full_name, e.email, e.phone, e.is_verified,
    e.branch_id, b.name AS branch_name, b.code AS branch_code,
    e.created_at, e.updated_at
  ''';

  // ============================================================
  // NEXT EMPLOYEE ID  (e.g. produces "EMP-7" following your existing pattern)
  // ============================================================

  Future<String> _generateNextEmployeeId() async {
    final result = await connection.execute('''
      SELECT COALESCE(MAX(CAST(SUBSTRING(employee_id FROM '[0-9]+\$') AS INT)), 0) + 1
      FROM employees
    ''');
    final next = result.first[0];
    return 'EMP-$next';
  }

  // ============================================================
  // CREATE MANAGER
  // ============================================================

  Future<Map<String, dynamic>> createManager(Map<String, dynamic> data) async {
    final employeeId = await _generateNextEmployeeId();

    final insertResult = await connection.execute(
      Sql.named('''
        INSERT INTO employees (
          employee_id, full_name, email, phone, role, password, is_verified, branch_id
        )
        VALUES (
          @employee_id, @full_name, @email, @phone, 'manager', @password, @is_verified, @branch_id
        )
        RETURNING id
      '''),
      parameters: {
        'employee_id': employeeId,
        'full_name': data['full_name'],
        'email': data['email'],
        'phone': data['phone'],
        'password': data['password'],
        'is_verified': data['is_verified'] ?? true,
        'branch_id': data['branch_id'],
      },
    );

    final newId = insertResult.first[0] as int;
    final created = await getManagerById(newId);
    return created!;
  }

  // ============================================================
  // GET ALL MANAGERS
  // ============================================================

  Future<List<Map<String, dynamic>>> getManagers() async {
    final result = await connection.execute('''
      SELECT $_selectColumns
      FROM employees e
      LEFT JOIN branches b ON b.id = e.branch_id
      WHERE e.role = 'manager'
      ORDER BY e.id DESC
    ''');

    return result.map(_mapManager).toList();
  }

  // ============================================================
  // GET MANAGER BY ID
  // ============================================================

  Future<Map<String, dynamic>?> getManagerById(int id) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM employees e
        LEFT JOIN branches b ON b.id = e.branch_id
        WHERE e.id = @id AND e.role = 'manager'
        LIMIT 1
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return _mapManager(result.first);
  }

  // ============================================================
  // UPDATE MANAGER
  // (password only changes if a non-empty one is provided)
  // ============================================================

  Future<Map<String, dynamic>?> updateManager(
    int id,
    Map<String, dynamic> data,
  ) async {
    final updateResult = await connection.execute(
      Sql.named('''
        UPDATE employees
        SET
          full_name = @full_name,
          email = @email,
          phone = @phone,
          is_verified = @is_verified,
          branch_id = @branch_id,
          password = COALESCE(NULLIF(@password, ''), password),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id AND role = 'manager'
        RETURNING id
      '''),
      parameters: {
        'id': id,
        'full_name': data['full_name'],
        'email': data['email'],
        'phone': data['phone'],
        'is_verified': data['is_verified'] ?? true,
        'branch_id': data['branch_id'],
        'password': data['password'] ?? '',
      },
    );

    if (updateResult.isEmpty) return null;
    return getManagerById(id);
  }

  // ============================================================
  // DELETE MANAGER
  // ============================================================

  Future<bool> deleteManager(int id) async {
    final result = await connection.execute(
      Sql.named('''
        DELETE FROM employees
        WHERE id = @id AND role = 'manager'
      '''),
      parameters: {'id': id},
    );

    return result.affectedRows > 0;
  }

  // ============================================================
  // MAP ROW
  // ============================================================

  Map<String, dynamic> _mapManager(ResultRow row) {
    return {
      'id': row[0],
      'employee_id': row[1],
      'full_name': row[2],
      'email': row[3],
      'phone': row[4],
      'is_verified': row[5],
      'branch_id': row[6],
      'branch_name': row[7],
      'branch_code': row[8],
      'created_at': row[9]?.toString(),
      'updated_at': row[10]?.toString(),
    };
  }
}