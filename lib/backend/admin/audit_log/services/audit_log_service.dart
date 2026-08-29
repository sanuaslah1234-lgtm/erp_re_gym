import 'package:erp_software/core/models/audit_log_model.dart';
import '../repositories/audit_log_repository.dart';

class AuditLogService {
  final AuditLogRepository repository;

  AuditLogService(this.repository);

  Future<Map<String, dynamic>> getLogsPage({
    String? search,
    String? action,
    String? module,
  }) async {
    final stats = await repository.getStats();
    final logsRaw = await repository.getLogs(search: search, action: action, module: module);
    final logs = logsRaw.map((r) => AuditLogModel.fromMap(r)).toList();

    return {
      'stats': stats,
      'logs': logs.map((l) => l.toJson()).toList(),
    };
  }

  Future<Map<String, dynamic>?> getEmployeeTimelinePage(int employeeDbId) async {
    final employee = await repository.getEmployeeInfo(employeeDbId);
    if (employee == null) return null;

    final stats = await repository.getEmployeeStats(employeeDbId);
    final timelineRaw = await repository.getEmployeeTimeline(employeeDbId);
    final timeline = timelineRaw.map((r) => AuditLogModel.fromMap(r)).toList();

    return {
      'employee': employee,
      'stats': stats,
      'timeline': timeline.map((t) => t.toJson()).toList(),
    };
  }
}
