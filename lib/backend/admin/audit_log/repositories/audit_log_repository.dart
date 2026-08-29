import 'package:postgres/postgres.dart';

class AuditLogRepository {
  final Connection connection;

  AuditLogRepository(this.connection);

  // ============================================================
  // STAT CARDS
  // ============================================================

  Future<Map<String, dynamic>> getStats() async {
    final result = await connection.execute('''
      SELECT
        COUNT(*)                                                       AS total_logs,
        COUNT(*) FILTER (WHERE module = 'Employee')                    AS employee_events,
        COUNT(*) FILTER (WHERE module = 'Auth')                        AS auth_events,
        COUNT(*) FILTER (WHERE created_at::date = CURRENT_DATE)        AS today
      FROM audit_logs
    ''');

    final row = result.first;
    return {
      'total_logs': row[0] as int,
      'employee_events': row[1] as int,
      'auth_events': row[2] as int,
      'today': row[3] as int,
    };
  }

  // ============================================================
  // FILTERED LOG LIST
  // ============================================================

  Future<List<Map<String, dynamic>>> getLogs({
    String? search,
    String? action,
    String? module,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT
          a.id, a.action, a.module, a.description, a.ip_address, a.created_at,
          e.id AS employee_db_id, e.employee_id, e.full_name, e.email
        FROM audit_logs a
        LEFT JOIN employees e ON e.id = a.employee_id
        WHERE
          (@search::text IS NULL OR (
            e.full_name ILIKE '%' || @search || '%'
            OR e.email ILIKE '%' || @search || '%'
            OR e.employee_id ILIKE '%' || @search || '%'
          ))
          AND (@action::text IS NULL OR a.action = @action)
          AND (@module::text IS NULL OR a.module = @module)
        ORDER BY a.created_at DESC
        LIMIT 200
      '''),
      parameters: {
        'search': (search == null || search.isEmpty) ? null : search,
        'action': (action == null || action.isEmpty || action == 'All Actions') ? null : action,
        'module': (module == null || module.isEmpty || module == 'All Modules') ? null : module,
      },
    );

    return result
        .map((row) => {
              'id': row[0],
              'action': row[1],
              'module': row[2],
              'description': row[3],
              'ip_address': row[4],
              'created_at': row[5]?.toString(),
              'employee_db_id': row[6],
              'employee_id': row[7],
              'employee_name': row[8],
              'employee_email': row[9],
            })
        .toList();
  }

  // ============================================================
  // EMPLOYEE INFO (for the timeline header card)
  // ============================================================

  Future<Map<String, dynamic>?> getEmployeeInfo(int employeeDbId) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT id, employee_id, full_name, email
        FROM employees
        WHERE id = @id
        LIMIT 1
      '''),
      parameters: {'id': employeeDbId},
    );

    if (result.isEmpty) return null;
    final row = result.first;
    return {
      'id': row[0],
      'employee_id': row[1],
      'full_name': row[2],
      'email': row[3],
    };
  }

  // ============================================================
  // EMPLOYEE TIMELINE STATS + ENTRIES
  // ============================================================

  Future<Map<String, dynamic>> getEmployeeStats(int employeeDbId) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT
          COUNT(*)                                       AS total_activities,
          COUNT(*) FILTER (WHERE action = 'LOGIN')        AS logins,
          COUNT(*) FILTER (WHERE action IN ('CREATE','UPDATE','DELETE')) AS updates
        FROM audit_logs
        WHERE employee_id = @id
      '''),
      parameters: {'id': employeeDbId},
    );

    final row = result.first;
    return {
      'total_activities': row[0] as int,
      'logins': row[1] as int,
      'updates': row[2] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getEmployeeTimeline(int employeeDbId) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT id, action, module, description, ip_address, created_at
        FROM audit_logs
        WHERE employee_id = @id
        ORDER BY created_at DESC
        LIMIT 200
      '''),
      parameters: {'id': employeeDbId},
    );

    return result
        .map((row) => {
              'id': row[0],
              'action': row[1],
              'module': row[2],
              'description': row[3],
              'ip_address': row[4],
              'created_at': row[5]?.toString(),
            })
        .toList();
  }
}