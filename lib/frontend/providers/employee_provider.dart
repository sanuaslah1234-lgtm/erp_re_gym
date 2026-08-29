import 'package:flutter/material.dart';
import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/frontend/services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service = EmployeeService();

  List<EmployeeModel> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _roleFilter = 'All Roles';

  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get roleFilter => _roleFilter;

  List<EmployeeModel> get filteredEmployees {
    return _employees.where((emp) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = (emp.fullName?.toLowerCase().contains(query) ?? false) ||
          (emp.employeeId?.toLowerCase().contains(query) ?? false) ||
          (emp.email.toLowerCase().contains(query)) ||
          (emp.displayBranch.toLowerCase().contains(query));

      final matchesRole = _roleFilter == 'All Roles' || _roleFilter == 'All' ||
          (emp.role?.toLowerCase() == _roleFilter.toLowerCase());

      return matchesSearch && matchesRole;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(String role) {
    _roleFilter = role;
    notifyListeners();
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await _service.getEmployees();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEmployee(dynamic tokenOrData, [Map<String, dynamic>? data]) async {
    final Map<String, dynamic> payload = data ?? (tokenOrData is Map<String, dynamic> ? tokenOrData : {});
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newEmp = await _service.createEmployee(
        fullName: payload['fullName'] ?? payload['full_name'] ?? '',
        email: payload['email'] ?? '',
        phone: payload['phone'] ?? '',
        password: payload['password'] ?? '123456',
        employeeId: payload['employeeId'] ?? payload['employee_id'],
        role: payload['role'],
        roleId: payload['roleId'] ?? payload['role_id'],
        branchId: payload['branchId'] ?? payload['branch_id'] ?? payload['department'],
        type: payload['type'] ?? payload['designation'],
      );
      _employees.insert(0, newEmp);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmployee(dynamic arg1, [dynamic arg2, Map<String, dynamic>? arg3]) async {
    String id;
    Map<String, dynamic> payload;
    if (arg3 != null) {
      id = arg2.toString();
      payload = arg3;
    } else {
      id = arg1.toString();
      payload = (arg2 is Map<String, dynamic>) ? arg2 : {};
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateEmployee(
        id: id,
        fullName: payload['fullName'] ?? payload['full_name'] ?? '',
        email: payload['email'] ?? '',
        phone: payload['phone'] ?? '',
        employeeId: payload['employeeId'] ?? payload['employee_id'],
        role: payload['role'],
        roleId: payload['roleId'] ?? payload['role_id'],
        branchId: payload['branchId'] ?? payload['branch_id'] ?? payload['department'],
        type: payload['type'] ?? payload['designation'],
      );
      final idx = _employees.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _employees[idx] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _service.deleteEmployee(id);
      _employees.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
