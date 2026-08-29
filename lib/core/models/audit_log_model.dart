class AuditLogModel {
  final int id;
  final String action;
  final String module;
  final String description;
  final String ipAddress;
  final DateTime? createdAt;
  final int? employeeDbId;
  final String? employeeId;
  final String? employeeName;
  final String? employeeEmail;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.module,
    required this.description,
    required this.ipAddress,
    this.createdAt,
    this.employeeDbId,
    this.employeeId,
    this.employeeName,
    this.employeeEmail,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) => AuditLogModel.fromMap(json);
  factory AuditLogModel.fromMap(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as int,
      action: json['action']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ipAddress: json['ip_address']?.toString() ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      employeeDbId: json['employee_db_id'] as int?,
      employeeId: json['employee_id']?.toString(),
      employeeName: json['employee_name']?.toString(),
      employeeEmail: json['employee_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'module': module,
      'description': description,
      'ip_address': ipAddress,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (employeeDbId != null) 'employee_db_id': employeeDbId,
      if (employeeId != null) 'employee_id': employeeId,
      if (employeeName != null) 'employee_name': employeeName,
      if (employeeEmail != null) 'employee_email': employeeEmail,
    };
  }
}