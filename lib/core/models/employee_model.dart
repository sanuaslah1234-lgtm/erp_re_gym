class EmployeeModel {
  final String? id;
  final String? fullName;
  final String email;
  final String? employeeId;
  final String phone;
  final String passwordHash;
  final String? plainPassword;

  final bool isVerified;
  final bool firstLogin;

  final String? verificationToken;
  final DateTime? verificationExpires;

  final String? role;
  final String? roleId;
  final String? type;
  final String? branchId;

  EmployeeModel({
    this.id,
    this.fullName,
    required this.email,
    this.employeeId,
    required this.phone,
    required this.passwordHash,
    this.plainPassword,
    this.isVerified = false,
    this.firstLogin = true,
    this.verificationToken,
    this.verificationExpires,
    this.role,
    this.roleId,
    this.type,
    this.branchId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel.fromMap(json);
  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id']?.toString(),
      fullName: map['full_name']?.toString(),
      email: map['email'].toString(),
      employeeId: map['employee_id']?.toString(),
      phone: map['phone'].toString(),
      passwordHash: map['password_hash']?.toString() ?? '',
      plainPassword: map['plain_password']?.toString(),
      isVerified: map['is_verified'] == true,
      firstLogin: map['first_login'] != false,
      verificationToken: map['verification_token']?.toString(),
      verificationExpires: map['verification_expires'] == null
          ? null
          : DateTime.tryParse(map['verification_expires'].toString()),
      role: map['role']?.toString(),
      roleId: map['role_id']?.toString(),
      type: map['type']?.toString(),
      branchId: map['branch_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'employee_id': employeeId,
      'phone': phone,
      'password_hash': passwordHash,
      'plain_password': plainPassword,
      'is_verified': isVerified,
      'first_login': firstLogin,
      'verification_token': verificationToken,
      'verification_expires': verificationExpires?.toIso8601String(),
      'role': role,
      'role_id': roleId,
      'type': type,
      'branch_id': branchId,
    };
  }

  // UI Helpers for Frontend
  bool get verified => isVerified;
  String get displayEmployeeId => employeeId ?? 'N/A';
  String get displayEmail => email;
  String get displayPhone => phone.isNotEmpty ? phone : 'N/A';
  String get displayBranch => branchId ?? 'HQ';
  String get displayRole => role?.toUpperCase() ?? 'EMPLOYEE';
  
  String get name => fullName ?? 'Unknown';
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';
}