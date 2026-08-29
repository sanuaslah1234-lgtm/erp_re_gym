import 'package:erp_software/core/constants/app_constants.dart';
import '/core/network/api_client.dart';
import 'package:erp_software/core/models/audit_log_model.dart';
import 'package:erp_software/core/models/audit_logs_page_result_model.dart';
import 'package:erp_software/core/models/audit_stats_model.dart';
import 'package:erp_software/core/models/employee_timeline_model.dart';

class AuditLogApiService {
  final ApiClient _client;

  AuditLogApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<AuditLogsPageResult> getLogs({
    String? search,
    String? action,
    String? module,
  }) async {
    final query = {
      if (search != null && search.isNotEmpty) 'search': search,
      if (action != null && action.isNotEmpty && action != 'All Actions') 'action': action,
      if (module != null && module.isNotEmpty && module != 'All Modules') 'module': module,
    };

    final uri = Uri.parse(AppConstants.auditLogs).replace(queryParameters: query);
    final data = await _client.get(uri.toString()) as Map<String, dynamic>;

    final stats = AuditStatsModel.fromJson(data['stats'] as Map<String, dynamic>);
    final logs = (data['logs'] as List<dynamic>)
        .map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return AuditLogsPageResult(stats: stats, logs: logs);
  }

  Future<EmployeeTimelinePage> getEmployeeTimeline(int employeeDbId) async {
    final data =
        await _client.get(AppConstants.employeeTimeline(employeeDbId)) as Map<String, dynamic>;

    return EmployeeTimelinePage(
      employee: EmployeeInfoModel.fromJson(data['employee'] as Map<String, dynamic>),
      stats: EmployeeTimelineStats.fromJson(data['stats'] as Map<String, dynamic>),
      timeline: (data['timeline'] as List<dynamic>)
          .map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
