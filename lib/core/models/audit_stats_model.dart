class AuditStatsModel {
  final int totalLogs;
  final int employeeEvents;
  final int authEvents;
  final int today;

  const AuditStatsModel({
    required this.totalLogs,
    required this.employeeEvents,
    required this.authEvents,
    required this.today,
  });

  factory AuditStatsModel.fromJson(Map<String, dynamic> json) => AuditStatsModel.fromMap(json);
  factory AuditStatsModel.fromMap(Map<String, dynamic> json) {
    return AuditStatsModel(
      totalLogs: (json['total_logs'] as num?)?.toInt() ?? 0,
      employeeEvents: (json['employee_events'] as num?)?.toInt() ?? 0,
      authEvents: (json['auth_events'] as num?)?.toInt() ?? 0,
      today: (json['today'] as num?)?.toInt() ?? 0,
    );
  }

  factory AuditStatsModel.empty() =>
      const AuditStatsModel(totalLogs: 0, employeeEvents: 0, authEvents: 0, today: 0);
}