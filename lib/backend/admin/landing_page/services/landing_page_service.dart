import 'package:erp_software/core/models/landing_page_model.dart';
import '../repositories/landing_page_repository.dart';

class LandingPageValidationException implements Exception {
  final String message;
  LandingPageValidationException(this.message);
}

class LandingPageService {
  final LandingPageRepository repository;

  LandingPageService(this.repository);

  Future<LandingPageModel> getSettings() async {
    final row = await repository.getSettings();
    return LandingPageModel.fromMap(row);
  }

  Future<LandingPageModel> updateSettings(Map<String, dynamic> data) async {
    final heroTitle = (data['hero_title'] as String?)?.trim() ?? '';
    if (heroTitle.isEmpty) {
      throw LandingPageValidationException('Hero Title is required');
    }

    final row = await repository.updateSettings(data);
    return LandingPageModel.fromMap(row);
  }

  Future<LandingPageModel> resetToDefaults() async {
    final row = await repository.resetToDefaults();
    return LandingPageModel.fromMap(row);
  }
}