import 'package:flutter/material.dart';
import 'package:erp_software/backend/models/brand_model.dart';
import 'package:erp_software/backend/models/cashier/product_model.dart';
import 'package:erp_software/backend/models/category_model.dart';
import 'package:erp_software/backend/models/purchase_model.dart';
import 'package:erp_software/backend/models/stock_movement_model.dart';
import 'package:erp_software/backend/models/supplier_model.dart';
import 'package:erp_software/backend/models/unit_model.dart';
import 'package:erp_software/frontend/services/product_management_api_service.dart';

class ProductManagementProvider with ChangeNotifier {
  final ProductManagementApiService apiService = ProductManagementApiService();

  List<ProductModel> _products = [
    ProductModel(
      id: 1,
      productCode: 'SKU-2255',
      barcode: '41e15b',
      name: 'sdsdffffffff',
      categoryId: 3,
      categoryName: 'Aslah',
      brand: 'ADIDAS',
      unit: 'kilogram',
      stockQuantity: 20,
      purchasePrice: 555.0,
      sellingPrice: 222.0,
      minimumStock: 5,
      isActive: true,
    ),
    ProductModel(
      id: 2,
      productCode: 'SKU-28',
      barcode: '325b44',
      name: 'ssssssseew',
      categoryId: 1,
      categoryName: 'Rihal',
      brand: 'Guchi',
      unit: 'BOX',
      stockQuantity: 0,
      purchasePrice: 599.0,
      sellingPrice: 450.0,
      minimumStock: 5,
      isActive: true,
    ),
  ];

  List<CategoryModel> _categories = [
    CategoryModel(id: 1, name: 'Rihal', description: 'rihalll', status: 'active', productCount: 1),
    CategoryModel(id: 2, name: 'salman', description: 'salman', status: 'active', productCount: 0),
    CategoryModel(id: 3, name: 'Aslah', description: 'aslah', status: 'active', productCount: 1),
    CategoryModel(id: 4, name: 'Anas', description: 'anas', status: 'active', productCount: 0),
  ];

  List<BrandModel> _brands = [
    BrandModel(id: 1, name: 'Guchi', description: 'Guchiiii', status: 'active', productCount: 1),
    BrandModel(id: 2, name: 'ADIDAS', description: 'IMPOSSIBLE IS NOTHING', status: 'active', productCount: 1),
    BrandModel(id: 3, name: 'NIKE', description: 'NOTHING IS IMPOSSIBLE', status: 'active', productCount: 0),
  ];

  List<UnitModel> _units = [
    UnitModel(id: 1, name: 'sdsdffffffff', shortSymbol: 'fdg', status: 'active', productCount: 0),
    UnitModel(id: 2, name: 'kilogram', shortSymbol: 'KG', status: 'active', productCount: 0),
    UnitModel(id: 3, name: 'BOX', shortSymbol: 'PIC', status: 'active', productCount: 0),
    UnitModel(id: 4, name: 'ANS222', shortSymbol: 'DPT00k', status: 'active', productCount: 0),
    UnitModel(id: 5, name: 'AnasZybo', shortSymbol: 'zy', status: 'active', productCount: 0),
    UnitModel(id: 6, name: 'anas', shortSymbol: 'DPT001', status: 'active', productCount: 0),
  ];

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
    notifyListeners();

    try {
      final results = await Future.wait([
        apiService.fetchProducts(
          token,
          search: _searchQuery,
          categoryId: _selectedCategoryId,
          status: _selectedStatus == 'all' ? null : _selectedStatus,
          lowStock: _lowStockFilter,
        ),
        apiService.fetchCategories(token),
        apiService.fetchBrands(token),
        apiService.fetchUnits(token),
        apiService.fetchSuppliers(token),
        apiService.fetchPurchases(token),
        apiService.fetchStockMovements(token),
      ]);

      _products = results[0] as List<ProductModel>;
      _categories = results[1] as List<CategoryModel>;
      _brands = results[2] as List<BrandModel>;
      _units = results[3] as List<UnitModel>;
      _suppliers = results[4] as List<SupplierModel>;
      _purchases = results[5] as List<PurchaseModel>;
      _stockMovements = results[6] as List<StockMovementModel>;
    } catch (e) {
      debugPrint('Backend API notice: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Unit Operations
  Future<bool> addUnit(String? token, UnitModel unit) async {
    final newUnit = UnitModel(
      id: _units.length + 1,
      name: unit.name,
      shortSymbol: unit.shortSymbol,
      status: unit.status,
      productCount: 0,
      createdAt: DateTime.now(),
    );
    _units.insert(0, newUnit);
    notifyListeners();

    try {
      await apiService.createUnit(token, unit);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  Future<bool> updateUnit(String? token, int id, UnitModel unit) async {
    final index = _units.indexWhere((u) => u.id == id);
    if (index != -1) {
      _units[index] = UnitModel(
        id: id,
        name: unit.name,
        shortSymbol: unit.shortSymbol,
        status: unit.status,
        productCount: _units[index].productCount,
        createdAt: _units[index].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
    try {
      await apiService.updateUnit(token, id, unit);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  Future<bool> deleteUnit(String? token, int id) async {
    _units.removeWhere((u) => u.id == id);
    notifyListeners();
    try {
      await apiService.deleteUnit(token, id);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }


  // Brand Operations
  Future<bool> addBrand(String? token, BrandModel brand) async {
    final newBrand = BrandModel(
      id: _brands.length + 1,
      name: brand.name,
      description: brand.description,
      status: brand.status,
      productCount: 0,
      createdAt: DateTime.now(),
    );
    _brands.insert(0, newBrand);
    notifyListeners();

    try {
      await apiService.createBrand(token, brand);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  Future<bool> updateBrand(String? token, int id, BrandModel brand) async {
    final index = _brands.indexWhere((b) => b.id == id);
    if (index != -1) {
      _brands[index] = BrandModel(
        id: id,
        name: brand.name,
        description: brand.description,
        status: brand.status,
        productCount: _brands[index].productCount,
        createdAt: _brands[index].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
    try {
      await apiService.updateBrand(token, id, brand);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  Future<bool> deleteBrand(String? token, int id) async {
    _brands.removeWhere((b) => b.id == id);
    notifyListeners();
    try {
      await apiService.deleteBrand(token, id);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  // Category Operations
  Future<bool> addCategory(String? token, CategoryModel category) async {
    final newCat = CategoryModel(
      id: _categories.length + 1,
      name: category.name,
      description: category.description,
      status: category.status,
      productCount: 0,
      createdAt: DateTime.now(),
    );
    _categories.insert(0, newCat);
    notifyListeners();

    try {
      await apiService.createCategory(token, category);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  Future<bool> deleteCategory(String? token, int id) async {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    try {
      await apiService.deleteCategory(token, id);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  // Product Operations
  Future<bool> saveProduct(String? token, ProductModel product) async {
    if (product.id != null) {
      final idx = _products.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        _products[idx] = product;
      }
    } else {
      final newProd = ProductModel(
        id: _products.length + 1,
        productCode: product.productCode,
        barcode: product.barcode ?? '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        name: product.name,
        categoryId: product.categoryId,
        categoryName: product.categoryName,
        supplierId: product.supplierId,
        supplierName: product.supplierName,
        brand: product.brand,
        purchasePrice: product.purchasePrice,
        sellingPrice: product.sellingPrice,
        taxPercentage: product.taxPercentage,
        openingStock: product.openingStock,
        stockQuantity: product.stockQuantity,
        minimumStock: product.minimumStock,
        unit: product.unit,
        imageUrl: product.imageUrl,
        description: product.description,
        isActive: product.isActive,
        createdAt: DateTime.now(),
      );
      _products.insert(0, newProd);
    }
    notifyListeners();

    try {
      if (product.id != null) {
        await apiService.updateProduct(token, product.id!, product);
      } else {
        await apiService.createProduct(token, product);
      }
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  Future<bool> deleteProduct(String? token, int id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    try {
      await apiService.deleteProduct(token, id);
      await loadAllData(token);
    } catch (_) {}
    return true;
  }

  Future<bool> addSupplier(String? token, SupplierModel supplier) async {
    _suppliers.add(supplier);
    notifyListeners();
    try {
      await apiService.createSupplier(token, supplier);
    } catch (_) {}
    return true;
  }

  Future<bool> createPurchase(String? token, PurchaseModel purchase) async {
    _purchases.add(purchase);
    notifyListeners();
    try {
      await apiService.createPurchase(token, purchase);
    } catch (_) {}
    return true;
  }

  Future<bool> recordStockAdjustment(
    String? token, {
    required int productId,
    required String movementType,
    required double quantity,
    required String reason,
  }) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final p = _products[idx];
      final newQty = (movementType == 'DAMAGE_OUT' || movementType == 'ADJUSTMENT_OUT')
          ? (p.stockQuantity - quantity).clamp(0.0, 999999.0)
          : p.stockQuantity + quantity;
      _products[idx] = ProductModel(
        id: p.id,
        productCode: p.productCode,
        barcode: p.barcode,
        name: p.name,
        categoryId: p.categoryId,
        categoryName: p.categoryName,
        supplierId: p.supplierId,
        supplierName: p.supplierName,
        brand: p.brand,
        purchasePrice: p.purchasePrice,
        sellingPrice: p.sellingPrice,
        taxPercentage: p.taxPercentage,
        openingStock: p.openingStock,
        stockQuantity: newQty,
        minimumStock: p.minimumStock,
        unit: p.unit,
        imageUrl: p.imageUrl,
        description: p.description,
        isActive: p.isActive,
      );
      notifyListeners();
    }
    try {
      await apiService.recordStockAdjustment(
        token,
        productId: productId,
        movementType: movementType,
        quantity: quantity,
        reason: reason,
      );
    } catch (_) {}
    return true;
  }
}
