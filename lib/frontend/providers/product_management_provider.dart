import 'package:flutter/material.dart';
import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/core/models/stock_movement_model.dart';
import 'package:erp_software/core/models/supplier_model.dart';
import 'package:erp_software/core/models/unit_model.dart';
import 'package:erp_software/frontend/services/product_management_api_service.dart';

class ProductManagementProvider with ChangeNotifier {
  final ProductManagementApiService apiService = ProductManagementApiService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  List<UnitModel> _units = [];
  List<SupplierModel> _suppliers = [];
  List<PurchaseModel> _purchases = [];
  List<StockMovementModel> _stockMovements = [];

  final Map<String, dynamic> _stockReport = {};
  final Map<String, dynamic> _profitLossReport = {};

  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  int? _selectedCategoryId;
  String _selectedStatus = 'all';
  bool _lowStockFilter = false;

  List<ProductModel> get products {
    if (_searchQuery.trim().isEmpty) return _products;
    final q = _searchQuery.toLowerCase();
    return _products.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.productCode.toLowerCase().contains(q) ||
      (p.barcode != null && p.barcode!.toLowerCase().contains(q)) ||
      (p.categoryName != null && p.categoryName!.toLowerCase().contains(q)) ||
      (p.brand != null && p.brand!.toLowerCase().contains(q))
    ).toList();
  }

  List<CategoryModel> get categories => _categories;
  List<BrandModel> get brands => _brands;
  List<UnitModel> get units => _units;
  List<SupplierModel> get suppliers => _suppliers;
  List<PurchaseModel> get purchases => _purchases;
  List<StockMovementModel> get stockMovements => _stockMovements;

  Map<String, dynamic> get stockReport => _stockReport;
  Map<String, dynamic> get profitLossReport => _profitLossReport;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  String get selectedStatus => _selectedStatus;
  bool get lowStockFilter => _lowStockFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setLowStockFilter(bool val) {
    _lowStockFilter = val;
    notifyListeners();
  }

  Future<void> loadAllData(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Each fetch runs independently — one failure doesn't kill the others
    try {
      _products = await apiService.fetchProducts(
        token,
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        lowStock: _lowStockFilter,
      );
    } catch (e) { debugPrint('Products fetch failed: $e'); }

    try { _categories = await apiService.fetchCategories(token); } catch (e) { debugPrint('Categories fetch failed: $e'); }
    try { _brands = await apiService.fetchBrands(token); } catch (e) { debugPrint('Brands fetch failed: $e'); }
    try { _units = await apiService.fetchUnits(token); } catch (e) { debugPrint('Units fetch failed: $e'); }
    try { _suppliers = await apiService.fetchSuppliers(token); } catch (e) { debugPrint('Suppliers fetch failed: $e'); }
    try { _purchases = await apiService.fetchPurchases(token); } catch (e) { debugPrint('Purchases fetch failed: $e'); }
    try { _stockMovements = await apiService.fetchStockMovements(token); } catch (e) { debugPrint('Stock movements fetch failed: $e'); }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // CATEGORY OPERATIONS — Backend first, reload on success
  // ============================================================

  Future<void> addCategory(String? token, CategoryModel category) async {
    await apiService.createCategory(token, category);
    await loadAllData(token);
  }

  Future<void> updateCategory(String? token, dynamic id, CategoryModel category) async {
    await apiService.updateCategory(token, id, category);
    await loadAllData(token);
  }

  Future<void> deleteCategory(String? token, dynamic id) async {
    await apiService.deleteCategory(token, id);
    await loadAllData(token);
  }

  // ============================================================
  // BRAND OPERATIONS — Backend first, reload on success
  // ============================================================

  Future<void> addBrand(String? token, BrandModel brand) async {
    await apiService.createBrand(token, brand);
    await loadAllData(token);
  }

  Future<void> updateBrand(String? token, dynamic id, BrandModel brand) async {
    await apiService.updateBrand(token, id, brand);
    await loadAllData(token);
  }

  Future<void> deleteBrand(String? token, dynamic id) async {
    await apiService.deleteBrand(token, id);
    await loadAllData(token);
  }

  // ============================================================
  // UNIT OPERATIONS — Backend first, reload on success
  // ============================================================

  Future<void> addUnit(String? token, UnitModel unit) async {
    await apiService.createUnit(token, unit);
    await loadAllData(token);
  }

  Future<void> updateUnit(String? token, dynamic id, UnitModel unit) async {
    await apiService.updateUnit(token, id, unit);
    await loadAllData(token);
  }

  Future<void> deleteUnit(String? token, dynamic id) async {
    await apiService.deleteUnit(token, id);
    await loadAllData(token);
  }

  // ============================================================
  // PRODUCT OPERATIONS — Backend first, reload on success
  // ============================================================

  Future<void> saveProduct(String? token, ProductModel product) async {
    if (product.id != null) {
      await apiService.updateProduct(token, product.id!, product);
    } else {
      await apiService.createProduct(token, product);
    }
    await loadAllData(token);
  }

  Future<void> deleteProduct(String? token, dynamic id) async {
    await apiService.deleteProduct(token, id);
    await loadAllData(token);
  }

  // ============================================================
  // SUPPLIER OPERATIONS — Backend first, reload on success
  // ============================================================

  Future<void> addSupplier(String? token, SupplierModel supplier) async {
    await apiService.createSupplier(token, supplier);
    await loadAllData(token);
  }

  Future<void> updateSupplier(String? token, dynamic id, SupplierModel supplier) async {
    await apiService.updateSupplier(token, id, supplier);
    await loadAllData(token);
  }

  Future<void> deleteSupplier(String? token, dynamic id) async {
    await apiService.deleteSupplier(token, id);
    await loadAllData(token);
  }

  // ============================================================
  // PURCHASE OPERATIONS — Backend first, reload on success
  // ============================================================

  Future<void> createPurchase(String? token, PurchaseModel purchase) async {
    await apiService.createPurchase(token, purchase);
    await loadAllData(token);
  }

  // ============================================================
  // STOCK ADJUSTMENT — Backend first, reload on success
  // ============================================================

  Future<void> recordStockAdjustment(
    String? token, {
    required dynamic productId,
    required String movementType,
    required double quantity,
    required String reason,
  }) async {
    await apiService.recordStockAdjustment(
      token,
      productId: productId,
      movementType: movementType,
      quantity: quantity,
      reason: reason,
    );
    await loadAllData(token);
  }
}
