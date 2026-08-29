class ManagerModel {
  final int? id;
  final String employeeId;
  final String fullName;
  final String email;
  final String phone;
  final bool isVerified;
  final int? branchId;
  final String? branchName;
  final String? branchCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ManagerModel({
    this.id,
    this.employeeId = '',
    required this.fullName,
    required this.email,
    required this.phone,
    this.isVerified = true,
    this.branchId,
    this.branchName,
    this.branchCode,
    this.createdAt,
    this.updatedAt,
  });

  factory ManagerModel.fromJson(Map<String, dynamic> json) => ManagerModel.fromMap(json);
  factory ManagerModel.fromMap(Map<String, dynamic> json) {
    return ManagerModel(
      id: json['id'] as int?,
      employeeId: json['employee_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isVerified: json['is_verified'] as bool? ?? true,
      branchId: json['branch_id'] as int?,
      branchName: json['branch_name']?.toString(),
      branchCode: json['branch_code']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => toRequestJson();
  Map<String, dynamic> toRequestJson({String password = ''}) {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'is_verified': isVerified,
      'branch_id': branchId,
      if (password.isNotEmpty) 'password': password,
    };
  }
}