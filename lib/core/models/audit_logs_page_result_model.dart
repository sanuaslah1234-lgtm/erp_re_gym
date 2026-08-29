import 'audit_log_model.dart';
import 'audit_stats_model.dart';

class AuditLogsPageResult {
  final AuditStatsModel stats;
  final List<AuditLogModel> logs;

  const AuditLogsPageResult({required this.stats, required this.logs});
}