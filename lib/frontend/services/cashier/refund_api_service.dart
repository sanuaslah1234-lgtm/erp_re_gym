import 'dart:convert';
import 'package:erp_software/core/models/cashier/refund.dart';
import 'package:http/http.dart' as http;

class RefundApiService {
  final String baseUrl = 'http://localhost:5000/api/cashier/refunds';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Refund> createRefund(String? token, Map<String, dynamic> refundData) async {
    final response = await http
        .post(Uri.parse(baseUrl), headers: _headers(token), body: jsonEncode(refundData))
        .timeout(const Duration(seconds: 6));

    final body = jsonDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) && body['success'] == true) {
      return Refund.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to process refund');
    }
  }

  Future<List<Refund>> getRefunds(String? token) async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: _headers(token)).timeout(const Duration(seconds: 4));
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final List list = body['data'];
        return list.map((e) => Refund.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? 'Failed to fetch refunds');
      }
    } catch (_) {
      return [];
    }
  }

  Future<Refund> getRefundById(String? token, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/$id'), headers: _headers(token)).timeout(const Duration(seconds: 4));
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return Refund.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch refund details');
    }
  }
}
