import 'package:postgres/postgres.dart';

/// Call this from any other controller to record an audit event, e.g.:
///
///   final auditLogger = AuditLogger(database.connection);
///   await auditLogger.log(
///     employeeId: currentEmployeeId,   // whoever performed the action
///     action: 'CREATE',
///     module: 'Branch',
///     description: 'Created branch ${branch.code}',
///   );
///
/// This is OPTIONAL and not wired into any existing controller automatically —
/// wire it in yourself wherever you know who the acting employee is
/// (e.g. once you have login/session handling).
class AuditLogger {
  final Connection connection;

  AuditLogger(this.connection);

  Future<void> log({
    required int employeeId,
    required String action, // LOGIN | LOGOUT | CREATE | UPDATE | DELETE
    required String module, // Employee | Branch | Manager | Reports | Auth | Settings
    required String description,
    String ipAddress = '::1',
  }) async {
    await connection.execute(
      Sql.named('''
        INSERT INTO audit_logs (employee_id, action, module, description, ip_address)
        VALUES (@employee_id, @action, @module, @description, @ip_address)
      '''),
      parameters: {
        'employee_id': employeeId,
        'action': action,
        'module': module,
        'description': description,
        'ip_address': ipAddress,
      },
    );
  }
}