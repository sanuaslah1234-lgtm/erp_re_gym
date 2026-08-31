import 'package:flutter/material.dart';
import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/core/models/user_model.dart';
import 'package:erp_software/frontend/services/auth_api_service.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();

  UserModel? _user;
  EmployeeModel? _employee;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  EmployeeModel? get employee => _employee;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;

  String get role => _user?.role ?? '';
  bool get isSuperAdmin => _user?.isSuperAdmin ?? false;
  bool get isAdmin => isSuperAdmin;

  /// Check if logged in user has a specific permission (e.g. 'gym.members.manage')
  bool can(String permission) => _user?.can(permission) ?? false;

  /// Check if logged in user has at least one of the listed permissions
  bool hasAnyPermission(List<String> perms) => _user?.hasAnyPermission(perms) ?? false;

  /// Check if user has access to ERP Management module
  bool canAccessErp() => _user?.canAccessErp ?? false;

  /// Check if user has access to Gym Management module
  bool canAccessGym() => _user?.canAccessGym ?? false;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResp = await _apiService.login(email, password);
      _token = authResp.token;
      _user = authResp.user;
      _employee = authResp.employee;
      GymApiService.setAuthToken(_token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    _user = null;
    _employee = null;
    _errorMessage = null;
    GymApiService.setAuthToken(null);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String? _lastGeneratedOtp;
  String? get lastGeneratedOtp => _lastGeneratedOtp;

  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastGeneratedOtp = await _apiService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return _lastGeneratedOtp;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.verifyOtp(email, otp);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.resetPassword(email, otp, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      GymApiService.setAuthToken(_token);
      final authResp = await _apiService.getMe(_token!);
      _user = authResp.user;
      _employee = authResp.employee;
      notifyListeners();
    } catch (_) {}
  }
}
