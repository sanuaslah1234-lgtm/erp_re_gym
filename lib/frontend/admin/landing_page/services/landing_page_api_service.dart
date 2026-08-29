import 'package:erp_software/core/constants/app_constants.dart';
import '/core/network/api_client.dart';
import 'package:erp_software/core/models/landing_page_model.dart';

class LandingPageApiService {
  final ApiClient _client;

  LandingPageApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<LandingPageModel> getSettings() async {
    final data = await _client.get(AppConstants.landingPage) as Map<String, dynamic>;
    return LandingPageModel.fromJson(data);
  }

  Future<LandingPageModel> updateSettings(LandingPageModel settings) async {
    final data = await _client.put(
      AppConstants.landingPage,
      settings.toRequestJson(),
    ) as Map<String, dynamic>;
    return LandingPageModel.fromJson(data);
  }

  Future<LandingPageModel> resetSettings() async {
    final data = await _client.post(AppConstants.landingPageReset, {}) as Map<String, dynamic>;
    return LandingPageModel.fromJson(data);
  }
}
