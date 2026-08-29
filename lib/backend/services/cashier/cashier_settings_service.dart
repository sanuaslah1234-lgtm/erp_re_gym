import 'package:erp_software/core/models/cashier/cashier_settings_model.dart';
import 'package:erp_software/backend/repositories/cashier/cashier_settings_repository.dart';

class CashierSettingsService {
  final CashierSettingsRepository settingsRepository;

  CashierSettingsService(this.settingsRepository);

  Future<CashierSettingsModel> getSettings() async {
    return await settingsRepository.getSettings();
  }

  Future<CashierSettingsModel> updateSettings(CashierSettingsModel settings) async {
    return await settingsRepository.updateSettings(settings);
  }
}
