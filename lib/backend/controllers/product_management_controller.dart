import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/core/models/supplier_model.dart';
import 'package:erp_software/core/models/unit_model.dart';
import 'package:erp_software/backend/services/product_management_service.dart';
import 'package:erp_software/backend/services/jwt_service.dart';

class ProductManagementController {
  final ProductManagementService service;

  ProductManagementController(this.service);

  Response _jsonResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  Response _errorResponse(String message, {int statusCode = 400}) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  // ----------------------------------------------------
  // PRODUCTS HANDLERS
  // ----------------------------------------------------
  Future<Response> getProducts(Request request) async {
    try {
      final params = request.url.queryParameters;
      final search = params['search'];
      final categoryId = params['categoryId'] != null ? int.tryParse(params['categoryId']!) : null;
      final statusFilter = params['status'];
      final lowStockOnly = params['lowStock'] == 'true';

      final products = await service.getProducts(
        search: search,
        categoryId: categoryId,
        statusFilter: statusFilter,
        lowStockOnly: lowStockOnly,
      );

      return _jsonResponse(products.map((p) => p.toJson()).toList());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> getProductById(Request request, String idStr) async {
    try {
      final product = await service.getProductById(idStr);
      if (product == null) return _errorResponse('Product not found', statusCode: 404);
      return _jsonResponse(product.toJson());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> createProduct(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final product = ProductModel.fromJson(payload);
      final user = request.context['user'];
      final userId = user is JwtPayload ? user.userId : request.context['userId'];

      final created = await service.createProduct(product, userId: userId);
      return _jsonResponse(created.toJson(), statusCode: 201);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> updateProduct(Request request, String idStr) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final product = ProductModel.fromJson(payload);

      final updated = await service.updateProduct(idStr, product);
      return _jsonResponse(updated.toJson());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> deleteProduct(Request request, String idStr) async {
    try {
      final wasDeleted = await service.deactivateProduct(idStr);
      return _jsonResponse({
        'success': true,
        'message': wasDeleted ? 'Product permanently deleted' : 'Product deactivated due to existing transaction history'
      });
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ----------------------------------------------------
  // CATEGORIES HANDLERS
  // ----------------------------------------------------
  Future<Response> getCategories(Request request) async {
    try {
      final categories = await service.getCategories();
      return _jsonResponse(categories.map((c) => c.toJson()).toList());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> createCategory(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final category = CategoryModel.fromJson(payload);
      final created = await service.createCategory(category);
      return _jsonResponse(created.toJson(), statusCode: 201);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> updateCategory(Request request, String idStr) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final category = CategoryModel.fromJson(payload);
      final updated = await service.updateCategory(idStr, category);
      return _jsonResponse(updated.toJson());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> deleteCategory(Request request, String idStr) async {
    try {
      await service.deleteCategory(idStr);
      return _jsonResponse({'success': true, 'message': 'Category deleted'});
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ----------------------------------------------------
  // BRANDS HANDLERS
  // ----------------------------------------------------
  Future<Response> getBrands(Request request) async {
    try {
      final brands = await service.getBrands();
      return _jsonResponse(brands.map((b) => b.toJson()).toList());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> createBrand(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final brand = BrandModel.fromJson(payload);
      final created = await service.createBrand(brand);
      return _jsonResponse(created.toJson(), statusCode: 201);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> updateBrand(Request request, String idStr) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final brand = BrandModel.fromJson(payload);
      final updated = await service.updateBrand(idStr, brand);
      return _jsonResponse(updated.toJson());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> deleteBrand(Request request, String idStr) async {
    try {
      await service.deleteBrand(idStr);
      return _jsonResponse({'success': true, 'message': 'Brand deleted'});
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ----------------------------------------------------
  // UNITS HANDLERS
  // ----------------------------------------------------
  Future<Response> getUnits(Request request) async {
    try {
      final units = await service.getUnits();
      return _jsonResponse(units.map((u) => u.toJson()).toList());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> createUnit(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final unit = UnitModel.fromJson(payload);
      final created = await service.createUnit(unit);
      return _jsonResponse(created.toJson(), statusCode: 201);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> updateUnit(Request request, String idStr) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final unit = UnitModel.fromJson(payload);
      final updated = await service.updateUnit(idStr, unit);
      return _jsonResponse(updated.toJson());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> deleteUnit(Request request, String idStr) async {
    try {
      await service.deleteUnit(idStr);
      return _jsonResponse({'success': true, 'message': 'Unit deleted'});
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ----------------------------------------------------
  // SUPPLIERS HANDLERS
  // ----------------------------------------------------
  Future<Response> getSuppliers(Request request) async {
    try {
      final suppliers = await service.getSuppliers();
      return _jsonResponse(suppliers.map((s) => s.toJson()).toList());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> createSupplier(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final supplier = SupplierModel.fromJson(payload);
      final created = await service.createSupplier(supplier);
      return _jsonResponse(created.toJson(), statusCode: 201);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> updateSupplier(Request request, String idStr) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final supplier = SupplierModel.fromJson(payload);
      final updated = await service.updateSupplier(idStr, supplier);
      return _jsonResponse(updated.toJson());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> deleteSupplier(Request request, String idStr) async {
    try {
      await service.deleteSupplier(idStr);
      return _jsonResponse({'message': 'Supplier deleted successfully'});
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ----------------------------------------------------
  // PURCHASES (STOCK IN) HANDLERS
  // ----------------------------------------------------
  Future<Response> getPurchases(Request request) async {
    try {
      final purchases = await service.getPurchases();
      return _jsonResponse(purchases.map((p) => p.toJson()).toList());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> createPurchase(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final purchase = PurchaseModel.fromJson(payload);
      final user = request.context['user'];
      final userId = user is JwtPayload ? user.userId : request.context['userId'];

      final created = await service.createPurchase(purchase, userId: userId);
      return _jsonResponse(created.toJson(), statusCode: 201);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> updatePurchase(Request request, String idStr) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final purchase = PurchaseModel.fromJson(payload);
      final updated = await service.updatePurchase(idStr, purchase);
      return _jsonResponse(updated.toJson());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> deletePurchase(Request request, String idStr) async {
    try {
      await service.deletePurchase(idStr);
      return _jsonResponse({'success': true, 'message': 'Purchase deleted'});
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ----------------------------------------------------
  // STOCK ADJUSTMENT / DAMAGE HANDLERS
  // ----------------------------------------------------
  Future<Response> recordStockAdjustment(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final productId = payload['productId'] ?? payload['product_id'];
      final quantity = (payload['quantity'] as num).toDouble();
      final reason = (payload['reason'] ?? '').toString();
      final movementType = payload['movementType']?.toString();
      final user = request.context['user'];
      final userId = user is JwtPayload ? user.userId : request.context['userId'];

      final result = await service.recordStockAdjustment(
        productId: productId,
        quantity: quantity,
        reason: reason,
        movementType: movementType,
        userId: userId,
      );

      return _jsonResponse(result, statusCode: 201);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> getStockMovements(Request request) async {
    try {
      final params = request.url.queryParameters;
      final productId = params['productId'] ?? params['product_id'];
      final movements = await service.getStockMovements(productId: productId);
      return _jsonResponse(movements.map((m) => m.toJson()).toList());
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ----------------------------------------------------
  // REPORTS HANDLERS
  // ----------------------------------------------------
  Future<Response> getStockValueReport(Request request) async {
    try {
      final report = await service.getStockValueReport();
      return _jsonResponse(report);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  Future<Response> getProfitLossReport(Request request) async {
    try {
      final report = await service.getProfitLossReport();
      return _jsonResponse(report);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }
}
