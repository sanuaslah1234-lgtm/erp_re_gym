import 'package:flutter/foundation.dart';
import 'package:erp_software/core/models/cashier/cashier_settings.dart';
import 'package:erp_software/frontend/services/cashier/cashier_settings_api_service.dart';

class CashierSettingsProvider extends ChangeNotifier {
  final CashierSettingsApiService _settingsApiService = CashierSettingsApiService();

  CashierSettings _settings = CashierSettings();
  bool _isLoading = false;
  String? _errorMessage;

  CashierSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSettings(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _settingsApiService.getSettings(token);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSettings(String? token, CashierSettings updatedSettings) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _settingsApiService.updateSettings(token, updatedSettings);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
