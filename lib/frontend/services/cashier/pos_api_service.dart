import 'dart:convert';
import 'package:erp_software/core/models/cashier/product.dart';
import 'package:http/http.dart' as http;

class PosApiService {
  final String baseUrl = 'http://localhost:5000/api/cashier';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<List<Product>> getProducts(String? token, {String? search, int? categoryId}) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null && categoryId > 0) 'categoryId': categoryId.toString(),
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
      // Fallback mock sample products if server is offline
      return _getMockProducts();
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
    return [
      {'id': 1, 'name': 'Food & Snacks'},
      {'id': 2, 'name': 'Beverages'},
      {'id': 3, 'name': 'Electronics'},
      {'id': 4, 'name': 'Stationery'},
    ];
  }

  List<Product> _getMockProducts() {
    return [
      Product(id: 1, productCode: 'PRD-001', barcode: '8901001000011', name: 'Organic Almond Milk 1L', purchasePrice: 3.50, sellingPrice: 4.99, taxPercentage: 5.0, stockQuantity: 150, unit: 'bottle'),
      Product(id: 2, productCode: 'PRD-002', barcode: '8901001000028', name: 'Dark Chocolate Bar 100g', purchasePrice: 1.20, sellingPrice: 2.50, taxPercentage: 5.0, stockQuantity: 300, unit: 'pcs'),
      Product(id: 3, productCode: 'PRD-003', barcode: '8901001000035', name: 'Wireless Ergonomic Mouse', purchasePrice: 12.00, sellingPrice: 24.99, taxPercentage: 10.0, stockQuantity: 45, unit: 'pcs'),
      Product(id: 4, productCode: 'PRD-004', barcode: '8901001000042', name: 'Premium Spiral Notebook A5', purchasePrice: 2.00, sellingPrice: 4.50, taxPercentage: 5.0, stockQuantity: 200, unit: 'pcs'),
      Product(id: 5, productCode: 'PRD-005', barcode: '8901001000059', name: 'Sparkling Mineral Water 500ml', purchasePrice: 0.80, sellingPrice: 1.75, taxPercentage: 5.0, stockQuantity: 500, unit: 'can'),
      Product(id: 6, productCode: 'PRD-006', barcode: '8901001000066', name: 'USB-C Fast Charger 30W', purchasePrice: 8.50, sellingPrice: 18.99, taxPercentage: 10.0, stockQuantity: 60, unit: 'pcs'),
    ];
  }
}
