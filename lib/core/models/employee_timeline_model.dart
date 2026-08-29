import 'audit_log_model.dart';

class EmployeeInfoModel {
  final int id;
  final String employeeId;
  final String fullName;
  final String email;

  const EmployeeInfoModel({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.email,
  });

  factory EmployeeInfoModel.fromJson(Map<String, dynamic> json) => EmployeeInfoModel.fromMap(json);
  factory EmployeeInfoModel.fromMap(Map<String, dynamic> json) {
    return EmployeeInfoModel(
      id: json['id'] as int,
      employeeId: json['employee_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class EmployeeTimelineStats {
  final int totalActivities;
  final int logins;
  final int updates;

  const EmployeeTimelineStats({
    required this.totalActivities,
    required this.logins,
    required this.updates,
  });

  factory EmployeeTimelineStats.fromJson(Map<String, dynamic> json) {
    return EmployeeTimelineStats(
      totalActivities: (json['total_activities'] as num?)?.toInt() ?? 0,
      logins: (json['logins'] as num?)?.toInt() ?? 0,
      updates: (json['updates'] as num?)?.toInt() ?? 0,
    );
  }
}

class EmployeeTimelinePage {
  final EmployeeInfoModel employee;
  final EmployeeTimelineStats stats;
  final List<AuditLogModel> timeline;

  const EmployeeTimelinePage({
    required this.employee,
    required this.stats,
    required this.timeline,
  });

  /// Groups the flat timeline list into date-headed sections,
  /// e.g. "Fri, Aug 14, 2026" -> [entries...]
  Map<String, List<AuditLogModel>> get groupedByDate {
    final Map<String, List<AuditLogModel>> grouped = {};
    for (final entry in timeline) {
      final date = entry.createdAt;
      final key = date == null
          ? 'Unknown date'
          : '${_weekday(date.weekday)}, ${_month(date.month)} ${date.day}, ${date.year}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }

  static String _weekday(int w) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}