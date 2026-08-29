import 'dart:convert';
import 'package:erp_software/core/models/cashier/cashier_settings.dart';
import 'package:http/http.dart' as http;

class CashierSettingsApiService {
  final String baseUrl = 'http://localhost:5000/api/cashier/settings';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<CashierSettings> getSettings(String? token) async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: _headers(token)).timeout(const Duration(seconds: 4));
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return CashierSettings.fromJson(body['data']);
      } else {
        throw Exception(body['message'] ?? 'Failed to fetch cashier settings');
      }
    } catch (_) {
      return CashierSettings();
    }
  }

  Future<CashierSettings> updateSettings(String? token, CashierSettings settings) async {
    final response = await http
        .put(Uri.parse(baseUrl), headers: _headers(token), body: jsonEncode(settings.toJson()))
        .timeout(const Duration(seconds: 5));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return CashierSettings.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to update cashier settings');
    }
  }
}
