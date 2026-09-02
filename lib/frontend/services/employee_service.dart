import 'dart:convert';

import 'package:erp_software/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

import 'package:erp_software/core/models/employee_model.dart';

class EmployeeService {
  static String get baseUrl => AppConstants.apiBaseUrl;

  // =========================================================
  // GET ALL EMPLOYEES
  // =========================================================

  Future<List<EmployeeModel>> getEmployees() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/employees'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load employees: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> data =
        decoded is List
            ? decoded
            : (decoded['data'] ?? []);

    return data
        .map(
          (item) => EmployeeModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // GET SINGLE EMPLOYEE
  // =========================================================

  Future<EmployeeModel> getEmployee(
    String id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/employees/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load employee: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    return EmployeeModel.fromJson(
      Map<String, dynamic>.from(
        decoded['data'] ?? decoded,
      ),
    );
  }

  // =========================================================
  // CREATE EMPLOYEE
  // =========================================================

  Future<EmployeeModel> createEmployee({
    required String fullName,
    String? employeeId,
    required String email,
    required String phone,
    required String password,
    String? role,
    String? roleId,
    String? branchId,
    String? type,
  }) async {
    final body = {
      'fullName': fullName,
      'employeeId': employeeId,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'roleId': roleId,
      'branchId': branchId,
      'type': type,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/employees'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      String errorMessage = 'Failed to create employee';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }

    final decoded = jsonDecode(response.body);

    return EmployeeModel.fromJson(
      Map<String, dynamic>.from(
        decoded['data'] ?? decoded,
      ),
    );
  }

  // =========================================================
  // UPDATE EMPLOYEE
  // =========================================================

  Future<EmployeeModel> updateEmployee({
    required String id,
    required String fullName,
    String? employeeId,
    required String email,
    required String phone,
    String? role,
    String? roleId,
    String? branchId,
    String? type,
  }) async {
    final body = {
      'fullName': fullName,
      'employeeId': employeeId,
      'email': email,
      'phone': phone,
      'role': role,
      'roleId': roleId,
      'branchId': branchId,
      'type': type,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/api/employees/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update employee: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    return EmployeeModel.fromJson(
      Map<String, dynamic>.from(
        decoded['data'] ?? decoded,
      ),
    );
  }

  // =========================================================
  // DELETE EMPLOYEE
  // =========================================================

  Future<void> deleteEmployee(
    String id,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/employees/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete employee: ${response.body}',
      );
    }
  }
}
