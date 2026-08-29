import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/landing_page_model.dart';
import '../services/landing_page_api_service.dart';

class LandingPageProvider extends ChangeNotifier {
  final LandingPageApiService _api;

  LandingPageProvider({LandingPageApiService? api}) : _api = api ?? LandingPageApiService();

  LandingPageModel _saved = const LandingPageModel();
  LandingPageModel draft = const LandingPageModel();

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  bool get isDirty {
    final s = _saved, d = draft;
    return d.logoText != s.logoText ||
        d.logoHighlight != s.logoHighlight ||
        d.loginButtonText != s.loginButtonText ||
        d.heroTag != s.heroTag ||
        d.heroTitle != s.heroTitle ||
        d.heroDescription != s.heroDescription ||
        d.heroButtonText != s.heroButtonText ||
        d.heroDashboardImageBase64 != s.heroDashboardImageBase64 ||
        d.heroBackgroundImageBase64 != s.heroBackgroundImageBase64 ||
        d.dashboardTitle != s.dashboardTitle ||
        d.dashboardSubtitle != s.dashboardSubtitle ||
        d.aboutTag != s.aboutTag ||
        d.aboutTitle != s.aboutTitle ||
        d.aboutDescription != s.aboutDescription ||
        d.aboutImage1Base64 != s.aboutImage1Base64 ||
        d.aboutImage2Base64 != s.aboutImage2Base64 ||
        d.aboutImage3Base64 != s.aboutImage3Base64 ||
        d.aboutImage4Base64 != s.aboutImage4Base64 ||
        d.footerText != s.footerText;
  }

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
      errorMessage = 'Failed to load landing page settings';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void update({
    String? logoText,
    String? logoHighlight,
    String? loginButtonText,
    String? heroTag,
    String? heroTitle,
    String? heroDescription,
    String? heroButtonText,
    String? heroDashboardImageBase64,
    String? heroBackgroundImageBase64,
    String? dashboardTitle,
    String? dashboardSubtitle,
    String? aboutTag,
    String? aboutTitle,
    String? aboutDescription,
    String? aboutImage1Base64,
    String? aboutImage2Base64,
    String? aboutImage3Base64,
    String? aboutImage4Base64,
    String? footerText,
  }) {
    draft = draft.copyWith(
      logoText: logoText,
      logoHighlight: logoHighlight,
      loginButtonText: loginButtonText,
      heroTag: heroTag,
      heroTitle: heroTitle,
      heroDescription: heroDescription,
      heroButtonText: heroButtonText,
      heroDashboardImageBase64: heroDashboardImageBase64,
      heroBackgroundImageBase64: heroBackgroundImageBase64,
      dashboardTitle: dashboardTitle,
      dashboardSubtitle: dashboardSubtitle,
      aboutTag: aboutTag,
      aboutTitle: aboutTitle,
      aboutDescription: aboutDescription,
      aboutImage1Base64: aboutImage1Base64,
      aboutImage2Base64: aboutImage2Base64,
      aboutImage3Base64: aboutImage3Base64,
      aboutImage4Base64: aboutImage4Base64,
      footerText: footerText,
    );
    notifyListeners();
  }

  Future<bool> save() async {
    if (draft.heroTitle.trim().isEmpty) {
      errorMessage = 'Hero Title is required';
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
      errorMessage = 'Failed to save landing page settings';
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
      errorMessage = 'Failed to reset landing page settings';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
