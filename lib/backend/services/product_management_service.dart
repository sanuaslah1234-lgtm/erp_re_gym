import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/core/models/stock_movement_model.dart';
import 'package:erp_software/core/models/supplier_model.dart';
import 'package:erp_software/core/models/unit_model.dart';
import 'package:erp_software/backend/repositories/product_management_repository.dart';

class ProductManagementService {
  final ProductManagementRepository repository;

  ProductManagementService(this.repository);

  // Products
  Future<List<ProductModel>> getProducts({
    String? search,
    int? categoryId,
    String? statusFilter,
    bool? lowStockOnly,
  }) async {
    return await repository.getAllProducts(
      search: search,
      categoryId: categoryId,
      statusFilter: statusFilter,
      lowStockOnly: lowStockOnly,
    );
  }

  Future<ProductModel?> getProductById(dynamic id) async {
    return await repository.getProductById(id);
  }

  Future<ProductModel> createProduct(ProductModel product, {dynamic userId}) async {
    if (product.name.trim().isEmpty) {
      throw Exception('Product name is required!');
    }
    if (product.productCode.trim().isEmpty) {
      throw Exception('Product code / SKU is required!');
    }
    if (product.sellingPrice < 0 || product.purchasePrice < 0) {
      throw Exception('Product price cannot be negative!');
    }
    return await repository.createProduct(product, userId: userId);
  }

  Future<ProductModel> updateProduct(dynamic id, ProductModel product) async {
    if (product.name.trim().isEmpty) {
      throw Exception('Product name is required!');
    }
    if (product.productCode.trim().isEmpty) {
      throw Exception('Product code / SKU is required!');
    }
    return await repository.updateProduct(id, product);
  }

  Future<bool> deactivateProduct(dynamic id) async {
    return await repository.deactivateProduct(id);
  }

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    return await repository.getAllCategories();
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    if (category.name.trim().isEmpty) {
      throw Exception('Category name is required!');
    }
    return await repository.createCategory(category);
  }

  Future<CategoryModel> updateCategory(dynamic id, CategoryModel category) async {
    if (category.name.trim().isEmpty) {
      throw Exception('Category name is required!');
    }
    return await repository.updateCategory(id, category);
  }

  Future<void> deleteCategory(dynamic id) async {
    await repository.deleteCategory(id);
  }

  // Brands
  Future<List<BrandModel>> getBrands() async {
    return await repository.getAllBrands();
  }

  Future<BrandModel> createBrand(BrandModel brand) async {
    if (brand.name.trim().isEmpty) {
      throw Exception('Brand name is required!');
    }
    return await repository.createBrand(brand);
  }

  Future<BrandModel> updateBrand(dynamic id, BrandModel brand) async {
    if (brand.name.trim().isEmpty) {
      throw Exception('Brand name is required!');
    }
    return await repository.updateBrand(id, brand);
  }

  Future<void> deleteBrand(dynamic id) async {
    await repository.deleteBrand(id);
  }

  // Units
  Future<List<UnitModel>> getUnits() async {
    return await repository.getAllUnits();
  }

  Future<UnitModel> createUnit(UnitModel unit) async {
    if (unit.name.trim().isEmpty) {
      throw Exception('Unit name is required!');
    }
    return await repository.createUnit(unit);
  }

  Future<UnitModel> updateUnit(dynamic id, UnitModel unit) async {
    if (unit.name.trim().isEmpty) {
      throw Exception('Unit name is required!');
    }
    return await repository.updateUnit(id, unit);
  }

  Future<void> deleteUnit(dynamic id) async {
    await repository.deleteUnit(id);
  }

  // Suppliers
  Future<List<SupplierModel>> getSuppliers() async {
    return await repository.getAllSuppliers();
  }

  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    if (supplier.name.trim().isEmpty) {
      throw Exception('Supplier name is required!');
    }
    return await repository.createSupplier(supplier);
  }

  Future<SupplierModel> updateSupplier(dynamic id, SupplierModel supplier) async {
    if (supplier.name.trim().isEmpty) {
      throw Exception('Supplier name is required!');
    }
    return await repository.updateSupplier(id, supplier);
  }

  Future<void> deleteSupplier(dynamic id) async {
    await repository.deleteSupplier(id);
  }

  // Purchases (Stock IN)
  Future<PurchaseModel> createPurchase(PurchaseModel purchase, {dynamic userId}) async {
    if (purchase.invoiceNumber.trim().isEmpty) {
      throw Exception('Purchase invoice number is required!');
    }
    return await repository.createPurchase(purchase, userId: userId);
  }

  Future<List<PurchaseModel>> getPurchases() async {
    return await repository.getAllPurchases();
  }

  Future<PurchaseModel?> getPurchaseById(dynamic id) async {
    return await repository.getPurchaseById(id);
  }

  Future<PurchaseModel> updatePurchase(dynamic id, PurchaseModel purchase) async {
    return await repository.updatePurchase(id, purchase);
  }

  Future<void> deletePurchase(dynamic id) async {
    await repository.deletePurchase(id);
  }

  // Stock Damage & Adjustments
  Future<Map<String, dynamic>> recordStockAdjustment({
    required dynamic productId,
    required double quantity,
    required String reason,
    String? movementType,
    dynamic userId,
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero!');
    }
    if (reason.trim().isEmpty) {
      throw Exception('Reason / notes required for stock adjustment!');
    }
    return await repository.recordStockAdjustment(
      productId: productId,
      adjustmentQuantity: quantity,
      reason: reason,
      movementType: movementType,
      userId: userId,
    );
  }

  // Stock History & Reports
  Future<List<StockMovementModel>> getStockMovements({dynamic productId}) async {
    return await repository.getStockMovements(productId: productId);
  }

  Future<Map<String, dynamic>> getStockValueReport() async {
    return await repository.getStockValueReport();
  }

  Future<Map<String, dynamic>> getProfitLossReport() async {
    return await repository.getProfitLossReport();
  }
}
