import 'package:erp_software/core/constants/app_permissions.dart';

class UserModel {
  final dynamic id;
  final String email;
  final String? passwordHash;
  final String? plainPassword;
  final String? employeeId;
  final dynamic roleId;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    required this.email,
    this.passwordHash,
    this.plainPassword,
    this.employeeId,
    this.roleId,
    this.role = 'SUPER_ADMIN',
    this.permissions = const [],
    this.isActive = true,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel.fromMap(json);

  factory UserModel.fromMap(Map<String, dynamic> json) {
    final roleStr = json['role']?.toString() ?? 'SUPER_ADMIN';
    List<String> perms = [];
    if (json['permissions'] != null && json['permissions'] is List) {
      perms = (json['permissions'] as List).map((e) => e.toString()).toList();
    } else {
      perms = AppPermissions.getPermissionsForRole(roleStr);
    }

    return UserModel(
      id: json['id'],
      email: json['email']?.toString() ?? '',
      passwordHash: json['password_hash']?.toString(),
      plainPassword: json['plain_password']?.toString(),
      employeeId: json['employee_id']?.toString(),
      roleId: json['role_id'],
      role: roleStr,
      permissions: perms,
      isActive: json['is_active'] == true || json['is_verified'] == true,
      lastLoginAt: json['last_login_at'] != null ? DateTime.tryParse(json['last_login_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson({bool includePassword = false}) {
    return {
      'id': id,
      'email': email,
      if (includePassword && passwordHash != null) 'password_hash': passwordHash,
      if (employeeId != null) 'employee_id': employeeId,
      if (roleId != null) 'role_id': roleId,
      'role': role,
      'permissions': permissions,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Whether user is dedicated Gym Super Admin
  bool get isGymSuperAdmin =>
      email.toLowerCase() == 'superadmingym@gmail.com' ||
      role.toUpperCase() == AppRoles.gymSuperAdmin;

  /// Whether user is dedicated Retail Super Admin
  bool get isRetailSuperAdmin =>
      email.toLowerCase() == 'superadminretail@gmail.com' ||
      role.toUpperCase() == AppRoles.retailSuperAdmin;

  /// Whether user has general SUPER_ADMIN role (bypasses all checks across both domains)
  bool get isSuperAdmin =>
      !isGymSuperAdmin &&
      !isRetailSuperAdmin &&
      (role.toUpperCase() == AppRoles.superAdmin || role.toLowerCase() == 'admin');

  /// Permission evaluation
  bool can(String permission) {
    if (isGymSuperAdmin) {
      return permission.startsWith('gym.');
    }
    if (isRetailSuperAdmin) {
      return permission.startsWith('erp.');
    }
    if (isSuperAdmin) return true;
    return permissions.contains(permission) || permissions.contains('*');
  }

  /// Check if user has at least one of the specified permissions
  bool hasAnyPermission(List<String> perms) {
    if (isGymSuperAdmin) {
      return perms.any((p) => p.startsWith('gym.'));
    }
    if (isRetailSuperAdmin) {
      return perms.any((p) => p.startsWith('erp.'));
    }
    if (isSuperAdmin) return true;
    return perms.any((p) => can(p));
  }

  /// Check if user has access to a specific module namespace ('erp' or 'gym')
  bool canAccessModule(String module) {
    if (isGymSuperAdmin) {
      return module == 'gym';
    }
    if (isRetailSuperAdmin) {
      return module == 'erp';
    }
    if (isSuperAdmin) return true;
    final prefix = '$module.';
    return permissions.any((p) => p.startsWith(prefix));
  }

  bool get canAccessErp => canAccessModule('erp');
  bool get canAccessGym => canAccessModule('gym');

  UserModel copyWith({
    dynamic id,
    String? email,
    String? passwordHash,
    String? plainPassword,
    String? employeeId,
    int? roleId,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      plainPassword: plainPassword ?? this.plainPassword,
      employeeId: employeeId ?? this.employeeId,
      roleId: roleId ?? this.roleId,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
