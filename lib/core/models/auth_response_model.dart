import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/core/models/user_model.dart';

class AuthResponseModel {
  final String token;
  final UserModel user;
  final EmployeeModel? employee;

  const AuthResponseModel({
    required this.token,
    required this.user,
    this.employee,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      if (employee != null) 'employee': employee!.toMap(),
    };
  }

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel.fromMap(json);

  factory AuthResponseModel.fromMap(Map<String, dynamic> map) {
    return AuthResponseModel(
      token: map['token']?.toString() ?? '',
      user: UserModel.fromJson(map['user'] as Map<String, dynamic>? ?? {}),
      employee: map['employee'] != null 
          ? EmployeeModel.fromMap(map['employee'] as Map<String, dynamic>) 
          : null,
    );
  }
}
