import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/core/models/stock_movement_model.dart';
import 'package:erp_software/core/models/supplier_model.dart';
import 'package:erp_software/core/models/unit_model.dart';

class ProductManagementApiService {
  final String baseUrl = 'http://localhost:5000/api';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  // Products API
  Future<List<ProductModel>> fetchProducts(
    String? token, {
    String? search,
    int? categoryId,
    String? status,
    bool? lowStock,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (categoryId != null && categoryId > 0) queryParams['categoryId'] = categoryId.toString();
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (lowStock == true) queryParams['lowStock'] = 'true';

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to load products');
  }

  Future<ProductModel> createProduct(String? token, ProductModel product) async {
    final res = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: _headers(token),
      body: jsonEncode(product.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to create product');
  }

  Future<ProductModel> updateProduct(String? token, dynamic id, ProductModel product) async {
    final res = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers(token),
      body: jsonEncode(product.toJson()),
    );

    if (res.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to update product');
  }

  Future<void> deleteProduct(String? token, dynamic id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to delete product');
    }
  }

  // Categories API
  Future<List<CategoryModel>> fetchCategories(String? token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to load categories');
  }

  Future<CategoryModel> createCategory(String? token, CategoryModel category) async {
    final res = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: _headers(token),
      body: jsonEncode(category.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return CategoryModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to create category');
  }

  Future<CategoryModel> updateCategory(String? token, dynamic id, CategoryModel category) async {
    final res = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: _headers(token),
      body: jsonEncode(category.toJson()),
    );

    if (res.statusCode == 200) {
      return CategoryModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to update category');
  }

  Future<void> deleteCategory(String? token, dynamic id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to delete category');
    }
  }

  // Brands API
  Future<List<BrandModel>> fetchBrands(String? token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/brands'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => BrandModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to load brands');
  }

  Future<BrandModel> createBrand(String? token, BrandModel brand) async {
    final res = await http.post(
      Uri.parse('$baseUrl/brands'),
      headers: _headers(token),
      body: jsonEncode(brand.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return BrandModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to create brand');
  }

  Future<BrandModel> updateBrand(String? token, dynamic id, BrandModel brand) async {
    final res = await http.put(
      Uri.parse('$baseUrl/brands/$id'),
      headers: _headers(token),
      body: jsonEncode(brand.toJson()),
    );

    if (res.statusCode == 200) {
      return BrandModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to update brand');
  }

  Future<void> deleteBrand(String? token, dynamic id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/brands/$id'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to delete brand');
    }
  }

  // Units API
  Future<List<UnitModel>> fetchUnits(String? token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/units'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => UnitModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to load units');
  }

  Future<UnitModel> createUnit(String? token, UnitModel unit) async {
    final res = await http.post(
      Uri.parse('$baseUrl/units'),
      headers: _headers(token),
      body: jsonEncode(unit.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return UnitModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to create unit');
  }

  Future<UnitModel> updateUnit(String? token, dynamic id, UnitModel unit) async {
    final res = await http.put(
      Uri.parse('$baseUrl/units/$id'),
      headers: _headers(token),
      body: jsonEncode(unit.toJson()),
    );

    if (res.statusCode == 200) {
      return UnitModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to update unit');
  }

  Future<void> deleteUnit(String? token, dynamic id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/units/$id'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to delete unit');
    }
  }


  // Suppliers API
  Future<List<SupplierModel>> fetchSuppliers(String? token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/suppliers'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => SupplierModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to load suppliers');
  }

  Future<SupplierModel> createSupplier(String? token, SupplierModel supplier) async {
    final res = await http.post(
      Uri.parse('$baseUrl/suppliers'),
      headers: _headers(token),
      body: jsonEncode(supplier.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return SupplierModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to create supplier');
  }

  Future<SupplierModel> updateSupplier(String? token, dynamic id, SupplierModel supplier) async {
    final res = await http.put(
      Uri.parse('$baseUrl/suppliers/$id'),
      headers: _headers(token),
      body: jsonEncode(supplier.toJson()),
    );

    if (res.statusCode == 200) {
      return SupplierModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to update supplier');
  }

  Future<void> deleteSupplier(String? token, dynamic id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/suppliers/$id'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to delete supplier');
    }
  }

  // Purchases (Stock IN) API
  Future<PurchaseModel> createPurchase(String? token, PurchaseModel purchase) async {
    final res = await http.post(
      Uri.parse('$baseUrl/purchases'),
      headers: _headers(token),
      body: jsonEncode(purchase.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return PurchaseModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to process purchase');
  }

  Future<List<PurchaseModel>> fetchPurchases(String? token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/purchases'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => PurchaseModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to load purchases');
  }

  // Stock Adjustments / Damage API
  Future<StockMovementModel> recordStockAdjustment(
    String? token, {
    required dynamic productId,
    required String movementType,
    required double quantity,
    required String reason,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/stock/adjustment'),
      headers: _headers(token),
      body: jsonEncode({
        'productId': productId,
        'movementType': movementType,
        'quantity': quantity,
        'reason': reason,
      }),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return StockMovementModel.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to record stock adjustment');
  }

  Future<List<StockMovementModel>> fetchStockMovements(String? token, {int? productId}) async {
    final uri = Uri.parse('$baseUrl/stock/movements').replace(
      queryParameters: productId != null ? {'productId': productId.toString()} : null,
    );
    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => StockMovementModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to load stock movements');
  }

  // Reports API
  Future<Map<String, dynamic>> fetchStockValueReport(String? token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/reports/stock-value'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load stock value report');
  }

  Future<Map<String, dynamic>> fetchProfitLossReport(String? token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/reports/profit-loss'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load profit loss report');
  }
}
