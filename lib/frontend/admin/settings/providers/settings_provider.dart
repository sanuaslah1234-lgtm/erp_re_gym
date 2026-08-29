import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/business_settings_model.dart';
import '../services/settings_api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsApiService _api;

  SettingsProvider({SettingsApiService? api}) : _api = api ?? SettingsApiService();

  BusinessSettingsModel _saved = const BusinessSettingsModel();
  BusinessSettingsModel draft = const BusinessSettingsModel();

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  bool get isDirty =>
      draft.companyName != _saved.companyName ||
      draft.legalTradeName != _saved.legalTradeName ||
      draft.taxVatNumber != _saved.taxVatNumber ||
      draft.officialEmail != _saved.officialEmail ||
      draft.businessPhone != _saved.businessPhone ||
      draft.headquartersAddress != _saved.headquartersAddress ||
      draft.companyLogoBase64 != _saved.companyLogoBase64;

  Future<void> fetchSettings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _saved = await _api.getSettings();
      draft = _saved;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load settings';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateDraft({
    String? companyLogoBase64,
    String? companyName,
    String? legalTradeName,
    String? taxVatNumber,
    String? officialEmail,
    String? businessPhone,
    String? headquartersAddress,
  }) {
    draft = draft.copyWith(
      companyLogoBase64: companyLogoBase64,
      companyName: companyName,
      legalTradeName: legalTradeName,
      taxVatNumber: taxVatNumber,
      officialEmail: officialEmail,
      businessPhone: businessPhone,
      headquartersAddress: headquartersAddress,
    );
    notifyListeners();
  }

  Future<bool> save() async {
    if (draft.companyName.trim().isEmpty) {
      errorMessage = 'Company Name is required';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      _saved = await _api.updateSettings(draft);
      draft = _saved;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Failed to save settings';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> resetToDefaults() async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      _saved = await _api.resetSettings();
      draft = _saved;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Failed to reset settings';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void discardChanges() {
    draft = _saved;
    notifyListeners();
  }
}
