import 'package:erp_software/core/models/business_settings_model.dart';
import '../repositories/settings_repository.dart';

class SettingsValidationException implements Exception {
  final String message;
  SettingsValidationException(this.message);
}

class SettingsService {
  final SettingsRepository repository;

  SettingsService(this.repository);

  Future<BusinessSettingsModel> getSettings() async {
    final row = await repository.getSettings();
    return BusinessSettingsModel.fromMap(row);
  }

  Future<BusinessSettingsModel> updateSettings(Map<String, dynamic> data) async {
    final companyName = (data['company_name'] as String?)?.trim() ?? '';
    if (companyName.isEmpty) {
      throw SettingsValidationException('Company Name is required');
    }

    final email = (data['official_email'] as String?)?.trim() ?? '';
    if (email.isNotEmpty &&
        !RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      throw SettingsValidationException('Enter a valid business email');
    }

    final row = await repository.updateSettings(data);
    return BusinessSettingsModel.fromMap(row);
  }

  Future<BusinessSettingsModel> resetToDefaults() async {
    final row = await repository.resetToDefaults();
    return BusinessSettingsModel.fromMap(row);
  }
}