import 'dart:convert';
import 'package:erp_software/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/models/warehouse_model.dart';

class WarehouseApiService {
  final String baseUrl = '${AppConfig.apiBaseUrl}/api';

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<List<WarehouseModel>> fetchWarehouses(String? token) async {
    final res = await http.get(Uri.parse('$baseUrl/warehouses'), headers: _headers(token));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List data = decoded is List ? decoded : (decoded['data'] ?? []);
      return data.map((item) => WarehouseModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to load warehouses');
  }

  Future<WarehouseModel> createWarehouse(String? token, WarehouseModel warehouse) async {
    final res = await http.post(
      Uri.parse('$baseUrl/warehouses'),
      headers: _headers(token),
      body: jsonEncode(warehouse.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return WarehouseModel.fromJson(decoded['data'] ?? decoded);
    }
    throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to create warehouse');
  }

  Future<WarehouseModel> updateWarehouse(String? token, String id, WarehouseModel warehouse) async {
    final res = await http.put(
      Uri.parse('$baseUrl/warehouses/$id'),
      headers: _headers(token),
      body: jsonEncode(warehouse.toJson()),
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return WarehouseModel.fromJson(decoded['data'] ?? decoded);
    }
    throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to update warehouse');
  }

  Future<void> deleteWarehouse(String? token, String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/warehouses/$id'), headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to delete warehouse');
    }
  }
}
