import 'dart:convert';
import 'package:erp_software/core/config/app_config.dart';
import 'package:erp_software/core/models/cashier/product.dart';
import 'package:http/http.dart' as http;

class PosApiService {
  final String baseUrl = '${AppConfig.apiBaseUrl}/api/cashier';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<List<Product>> getProducts(String? token, {String? search, int? categoryId, int? brandId}) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null && categoryId > 0) 'categoryId': categoryId.toString(),
        if (brandId != null && brandId > 0) 'brandId': brandId.toString(),
      });

      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 4));
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final List list = body['data'];
        return list.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? 'Failed to fetch POS products');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Product> getProductByBarcode(String? token, String barcode) async {
    final response = await http
        .get(Uri.parse('$baseUrl/products/barcode/$barcode'), headers: _headers(token))
        .timeout(const Duration(seconds: 4));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return Product.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Product with barcode "$barcode" not found');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(String? token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'), headers: _headers(token)).timeout(const Duration(seconds: 4));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return (body['data'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getBrands(String? token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/brands'), headers: _headers(token)).timeout(const Duration(seconds: 4));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return (body['data'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
