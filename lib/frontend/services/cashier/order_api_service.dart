import 'dart:convert';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  final String baseUrl = 'http://localhost:5000/api/cashier/orders';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<PosOrder> createOrder(String? token, Map<String, dynamic> orderData) async {
    final response = await http
        .post(Uri.parse(baseUrl), headers: _headers(token), body: jsonEncode(orderData))
        .timeout(const Duration(seconds: 6));

    final body = jsonDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) && body['success'] == true) {
      return PosOrder.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to complete POS order');
    }
  }

  Future<List<PosOrder>> getOrders(
    String? token, {
    String? search,
    String? status,
    String? paymentMethod,
    String? date,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (paymentMethod != null && paymentMethod.isNotEmpty) 'paymentMethod': paymentMethod,
        if (date != null && date.isNotEmpty) 'date': date,
      });

      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 4));
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final List list = body['data'];
        return list.map((e) => PosOrder.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? 'Failed to fetch POS orders');
      }
    } catch (e) {
      return [];
    }
  }

  Future<PosOrder> getOrderById(String? token, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/$id'), headers: _headers(token)).timeout(const Duration(seconds: 4));
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return PosOrder.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch order details');
    }
  }

  Future<bool> cancelOrder(String? token, int id) async {
    final response = await http.post(Uri.parse('$baseUrl/api/$id/cancel'), headers: _headers(token)).timeout(const Duration(seconds: 5));
    final body = jsonDecode(response.body);
    return response.statusCode == 200 && body['success'] == true;
  }
}
