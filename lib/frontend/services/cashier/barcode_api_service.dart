import 'dart:convert';
import 'package:erp_software/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class BarcodeApiService {
  final String baseUrl = '${AppConfig.apiBaseUrl}/api/cashier/barcodes';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> recordBarcodePrint(String? token, dynamic productId, String barcode, int labelQuantity) async {
    final numericProductId = productId is int ? productId : (int.tryParse(productId.toString()) ?? 1);
    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: _headers(token),
          body: jsonEncode({
            'productId': numericProductId,
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
