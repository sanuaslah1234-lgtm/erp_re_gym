import 'dart:convert';
import 'package:erp_software/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

class BarcodeApiService {
  String get baseUrl => '${AppConstants.apiBaseUrl}/api/cashier/barcodes';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> recordBarcodePrint(String? token, int productId, String barcode, int labelQuantity) async {
    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: _headers(token),
          body: jsonEncode({
            'productId': productId,
            'barcode': barcode,
            'labelQuantity': labelQuantity,
          }),
        )
        .timeout(const Duration(seconds: 4));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return body['data'];
    } else {
      throw Exception(body['message'] ?? 'Failed to record barcode print');
    }
  }

  Future<List<dynamic>> getBarcodeHistory(String? token) async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: _headers(token)).timeout(const Duration(seconds: 4));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return body['data'];
      }
    } catch (_) {}
    return [];
  }
}
