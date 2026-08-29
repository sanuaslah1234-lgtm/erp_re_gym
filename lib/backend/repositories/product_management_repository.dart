import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/core/models/stock_movement_model.dart';
import 'package:erp_software/core/models/supplier_model.dart';
import 'package:erp_software/core/models/unit_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class ProductManagementRepository {
  final PostgresService db;

  ProductManagementRepository(this.db);

  // ----------------------------------------------------
  // PRODUCTS CRUD & STOCK MANAGEMENT
  // ----------------------------------------------------
  Future<List<ProductModel>> getAllProducts({
    String? search,
    int? categoryId,
    String? statusFilter,
    bool? lowStockOnly,
  }) async {
    String sql = '''
      SELECT 
        p.id,
        p.name,
        COALESCE(p.sku, '') as product_code,
        COALESCE(p.sku, '') as barcode,
        p.category_id,
        c.name as category_name,
        p.brand_id,
        b.name as brand,
        p.unit_id,
        u.name as unit,
        COALESCE(p.cost_price, 0) as purchase_price,
        COALESCE(p.selling_price, 0) as selling_price,
        0 as tax_percentage,
        0 as opening_stock,
        0 as stock_quantity,
        0 as minimum_stock,
        p.description,
        p.image as image_url,
        CASE WHEN LOWER(COALESCE(p.status, 'active')) = 'active' THEN true ELSE false END as is_active,
        p.created_at,
        p.updated_at
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN brands b ON p.brand_id = b.id
      LEFT JOIN units u ON p.unit_id = u.id
      WHERE 1=1
    ''';

    final params = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      sql += ' AND (LOWER(p.name) LIKE LOWER(@search) OR LOWER(COALESCE(p.sku, \'\')) LIKE LOWER(@search))';
      params['search'] = '%${search.trim()}%';
    }

    if (categoryId != null && categoryId > 0) {
      sql += ' AND p.category_id = @catId';
      params['catId'] = categoryId.toString();
    }

    if (statusFilter == 'active') {
      sql += ' AND LOWER(COALESCE(p.status, \'active\')) = \'active\'';
    } else if (statusFilter == 'inactive') {
      sql += ' AND LOWER(COALESCE(p.status, \'active\')) = \'inactive\'';
    }

    sql += ' ORDER BY p.name ASC';

    final result = await db.connection.execute(Sql.named(sql), parameters: params);

    return result.map((row) {
      return ProductModel.fromJson(row.toColumnMap());
    }).toList();
  }

  Future<ProductModel?> getProductById(dynamic id) async {
    final sql = '''
      SELECT 
        p.id,
        p.name,
        COALESCE(p.sku, '') as product_code,
        COALESCE(p.sku, '') as barcode,
        p.category_id,
        c.name as category_name,
        p.brand_id,
        b.name as brand,
        p.unit_id,
        u.name as unit,
        COALESCE(p.cost_price, 0) as purchase_price,
        COALESCE(p.selling_price, 0) as selling_price,
        0 as tax_percentage,
        0 as opening_stock,
        0 as stock_quantity,
        0 as minimum_stock,
        p.description,
        p.image as image_url,
        CASE WHEN LOWER(COALESCE(p.status, 'active')) = 'active' THEN true ELSE false END as is_active,
        p.created_at,
        p.updated_at
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN brands b ON p.brand_id = b.id
      LEFT JOIN units u ON p.unit_id = u.id
      WHERE p.id = @id OR p.id::text = @idStr
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'id': id.toString(), 'idStr': id.toString()});
    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<ProductModel?> findByProductCode(String code) async {
    final sql = '''
      SELECT 
        p.id,
        p.name,
        COALESCE(p.sku, '') as product_code,
        COALESCE(p.sku, '') as barcode,
        p.category_id,
        c.name as category_name,
        p.brand_id,
        b.name as brand,
        p.unit_id,
        u.name as unit,
        COALESCE(p.cost_price, 0) as purchase_price,
        COALESCE(p.selling_price, 0) as selling_price,
        0 as tax_percentage,
        0 as opening_stock,
        0 as stock_quantity,
        0 as minimum_stock,
        p.description,
        p.image as image_url,
        CASE WHEN LOWER(COALESCE(p.status, 'active')) = 'active' THEN true ELSE false END as is_active,
        p.created_at,
        p.updated_at
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN brands b ON p.brand_id = b.id
      LEFT JOIN units u ON p.unit_id = u.id
      WHERE LOWER(p.sku) = LOWER(@code)
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'code': code.trim()});
    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<ProductModel> createProduct(ProductModel p, {int? userId}) async {
    final existing = await findByProductCode(p.productCode);
    if (existing != null) {
      throw Exception('Product code / SKU "${p.productCode}" already exists!');
    }

    final sql = '''
      INSERT INTO products (
        name, sku, category_id, brand_id, unit_id,
        cost_price, selling_price, description, image, status
      ) VALUES (
        @name, @code, @catId, @brandId, @unitId,
        @pPrice, @sPrice, @desc, @img, @status
      ) RETURNING id;
    ''';

    final params = {
      'code': p.productCode.trim(),
      'name': p.name.trim(),
      'catId': p.categoryId?.toString(),
      'brandId': p.brand?.toString(),
      'unitId': p.unit,
      'pPrice': p.purchasePrice,
      'sPrice': p.sellingPrice,
      'img': p.imageUrl?.trim(),
      'desc': p.description?.trim(),
      'status': p.isActive ? 'active' : 'inactive',
    };

    final result = await db.connection.execute(Sql.named(sql), parameters: params);
    final newId = result.first[0];

    return (await getProductById(newId))!;
  }

  Future<ProductModel> updateProduct(dynamic id, ProductModel p) async {
    final sql = '''
      UPDATE products SET
        sku = @code,
        name = @name,
        category_id = @catId,
        cost_price = @pPrice,
        selling_price = @sPrice,
        image = @img,
        description = @desc,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id OR id::text = @idStr;
    ''';

    final params = {
      'id': id.toString(),
      'idStr': id.toString(),
      'code': p.productCode.trim(),
      'name': p.name.trim(),
      'catId': p.categoryId?.toString(),
      'pPrice': p.purchasePrice,
      'sPrice': p.sellingPrice,
      'img': p.imageUrl?.trim(),
      'desc': p.description?.trim(),
      'status': p.isActive ? 'active' : 'inactive',
    };

    await db.connection.execute(Sql.named(sql), parameters: params);
    final updated = await getProductById(id);
    if (updated == null) throw Exception('Product not found after update');
    return updated;
  }

  Future<bool> deactivateProduct(dynamic id) async {
    await db.connection.execute(
      Sql.named("UPDATE products SET status = 'inactive', updated_at = CURRENT_TIMESTAMP WHERE id = @id OR id::text = @idStr"),
      parameters: {'id': id.toString(), 'idStr': id.toString()},
    );
    return true;
  }

  // ----------------------------------------------------
  // CATEGORIES CRUD
  // ----------------------------------------------------
  Future<List<CategoryModel>> getAllCategories() async {
    final sql = '''
      SELECT 
        c.id, 
        c.name, 
        c.description, 
        COALESCE(c.status, 'active') as status, 
        COALESCE(c.created_at, CURRENT_TIMESTAMP) as created_at, 
        COALESCE(c.updated_at, CURRENT_TIMESTAMP) as updated_at, 
        COUNT(p.id) as product_count
      FROM categories c
      LEFT JOIN products p ON p.category_id = c.id
      GROUP BY c.id, c.name, c.description, c.status, c.created_at, c.updated_at
      ORDER BY c.name ASC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) {
      return CategoryModel.fromJson(row.toColumnMap());
    }).toList();
  }

  Future<CategoryModel> createCategory(CategoryModel cat) async {
    final sql = '''
      INSERT INTO categories (name, description, status)
      VALUES (@name, @desc, @status)
      RETURNING id, name, description, status, created_at, updated_at;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'name': cat.name.trim(),
        'desc': cat.description?.trim(),
        'status': cat.status,
      },
    );
    final row = result.first.toColumnMap();
    return CategoryModel.fromJson(row);
  }

  Future<CategoryModel> updateCategory(dynamic id, CategoryModel cat) async {
    final sql = '''
      UPDATE categories SET
        name = @name,
        description = @desc,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id OR id::text = @idStr;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id.toString(),
        'idStr': id.toString(),
        'name': cat.name.trim(),
        'desc': cat.description?.trim(),
        'status': cat.status,
      },
    );
    return CategoryModel(id: id, name: cat.name.trim(), description: cat.description?.trim(), status: cat.status);
  }

  Future<void> deleteCategory(dynamic id) async {
    await db.connection.execute(
      Sql.named('DELETE FROM categories WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': id.toString(), 'idStr': id.toString()},
    );
  }

  // ----------------------------------------------------
  // BRANDS CRUD
  // ----------------------------------------------------
  Future<List<BrandModel>> getAllBrands() async {
    final sql = '''
      SELECT 
        b.id, 
        b.name, 
        b.description, 
        COALESCE(b.status, 'active') as status, 
        COALESCE(b.created_at, CURRENT_TIMESTAMP) as created_at, 
        COALESCE(b.updated_at, CURRENT_TIMESTAMP) as updated_at, 
        COUNT(p.id) as product_count
      FROM brands b
      LEFT JOIN products p ON p.brand_id = b.id
      GROUP BY b.id, b.name, b.description, b.status, b.created_at, b.updated_at
      ORDER BY b.name ASC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) {
      return BrandModel.fromJson(row.toColumnMap());
    }).toList();
  }

  Future<BrandModel> createBrand(BrandModel brand) async {
    final sql = '''
      INSERT INTO brands (name, description, status)
      VALUES (@name, @desc, @status)
      RETURNING id, name, description, status, created_at, updated_at;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'name': brand.name.trim(),
        'desc': brand.description?.trim(),
        'status': brand.status,
      },
    );
    return BrandModel.fromJson(result.first.toColumnMap());
  }

  Future<BrandModel> updateBrand(dynamic id, BrandModel brand) async {
    final sql = '''
      UPDATE brands SET
        name = @name,
        description = @desc,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id OR id::text = @idStr;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id.toString(),
        'idStr': id.toString(),
        'name': brand.name.trim(),
        'desc': brand.description?.trim(),
        'status': brand.status,
      },
    );
    return BrandModel(id: id, name: brand.name.trim(), description: brand.description?.trim(), status: brand.status);
  }

  Future<void> deleteBrand(dynamic id) async {
    await db.connection.execute(
      Sql.named('DELETE FROM brands WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': id.toString(), 'idStr': id.toString()},
    );
  }

  // ----------------------------------------------------
  // UNITS CRUD
  // ----------------------------------------------------
  Future<List<UnitModel>> getAllUnits() async {
    final sql = '''
      SELECT 
        u.id, 
        u.name, 
        u.code as short_symbol, 
        COALESCE(u.status, 'active') as status, 
        COALESCE(u.created_at, CURRENT_TIMESTAMP) as created_at, 
        COALESCE(u.updated_at, CURRENT_TIMESTAMP) as updated_at, 
        COUNT(p.id) as product_count
      FROM units u
      LEFT JOIN products p ON p.unit_id = u.id
      GROUP BY u.id, u.name, u.code, u.status, u.created_at, u.updated_at
      ORDER BY u.name ASC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) {
      return UnitModel.fromJson(row.toColumnMap());
    }).toList();
  }

  Future<UnitModel> createUnit(UnitModel unit) async {
    final sql = '''
      INSERT INTO units (name, code, status)
      VALUES (@name, @symbol, @status)
      RETURNING id, name, code as short_symbol, status, created_at, updated_at;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'name': unit.name.trim(),
        'symbol': unit.shortSymbol.trim(),
        'status': unit.status,
      },
    );
    return UnitModel.fromJson(result.first.toColumnMap());
  }

  Future<UnitModel> updateUnit(dynamic id, UnitModel unit) async {
    final sql = '''
      UPDATE units SET
        name = @name,
        code = @symbol,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id OR id::text = @idStr;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id.toString(),
        'idStr': id.toString(),
        'name': unit.name.trim(),
        'symbol': unit.shortSymbol.trim(),
        'status': unit.status,
      },
    );
    return UnitModel(
      id: id,
      name: unit.name.trim(),
      shortSymbol: unit.shortSymbol.trim(),
      status: unit.status,
    );
  }

  Future<void> deleteUnit(dynamic id) async {
    await db.connection.execute(
      Sql.named('DELETE FROM units WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': id.toString(), 'idStr': id.toString()},
    );
  }

  // ----------------------------------------------------
  // SUPPLIERS CRUD
  // ----------------------------------------------------
  Future<List<SupplierModel>> getAllSuppliers() async {
    final sql = '''
      SELECT 
        s.id,
        s.company_name as name,
        s.company_name as supplier_code,
        s.phone,
        s.email,
        s.address,
        s.tax_number as gst_vat_number,
        COALESCE(s.status, 'active') as status,
        COALESCE(s.created_at, CURRENT_TIMESTAMP) as created_at,
        COALESCE(s.updated_at, CURRENT_TIMESTAMP) as updated_at
      FROM suppliers s
      ORDER BY s.company_name ASC
    ''';
    final result = await db.connection.execute(sql);
    return result.map((row) => SupplierModel.fromJson(row.toColumnMap())).toList();
  }

  Future<SupplierModel> createSupplier(SupplierModel sup) async {
    final sql = '''
      INSERT INTO suppliers (company_name, contact_person, phone, email, address, tax_number, status)
      VALUES (@name, @name, @phone, @email, @address, @gst, @status)
      RETURNING id, company_name as name, company_name as supplier_code, phone, email, address, tax_number as gst_vat_number, status, created_at, updated_at;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'name': sup.name.trim(),
        'phone': sup.phone?.trim(),
        'email': sup.email?.trim(),
        'address': sup.address?.trim(),
        'gst': sup.gstVatNumber?.trim(),
        'status': sup.status,
      },
    );
    return SupplierModel.fromJson(result.first.toColumnMap());
  }

  Future<SupplierModel> updateSupplier(dynamic id, SupplierModel sup) async {
    final sql = '''
      UPDATE suppliers SET
        company_name = @name,
        phone = @phone,
        email = @email,
        address = @address,
        tax_number = @gst,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id OR id::text = @idStr;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id.toString(),
        'idStr': id.toString(),
        'name': sup.name.trim(),
        'phone': sup.phone?.trim(),
        'email': sup.email?.trim(),
        'address': sup.address?.trim(),
        'gst': sup.gstVatNumber?.trim(),
        'status': sup.status,
      },
    );
    return SupplierModel(
      id: id,
      supplierCode: sup.supplierCode.trim(),
      name: sup.name.trim(),
      phone: sup.phone?.trim(),
      email: sup.email?.trim(),
      address: sup.address?.trim(),
      gstVatNumber: sup.gstVatNumber?.trim(),
      status: sup.status,
    );
  }

  // ----------------------------------------------------
  // PURCHASES CRUD
  // ----------------------------------------------------
  Future<List<PurchaseModel>> getAllPurchases() async {
    final sql = '''
      SELECT 
        pu.id,
        pu.purchase_no as invoice_number,
        pu.supplier_id,
        COALESCE(s.company_name, 'General Supplier') as supplier_name,
        COALESCE(pu.purchase_date, CURRENT_TIMESTAMP) as purchase_date,
        COALESCE(pu.total_amount, 0) as total_amount,
        COALESCE(pu.total_amount, 0) as paid_amount,
        0 as due_amount,
        'paid' as payment_status,
        COALESCE(pu.status, 'received') as status,
        pu.notes,
        COALESCE(pu.created_at, CURRENT_TIMESTAMP) as created_at,
        COALESCE(pu.updated_at, CURRENT_TIMESTAMP) as updated_at
      FROM purchases pu
      LEFT JOIN suppliers s ON pu.supplier_id = s.id
      ORDER BY pu.purchase_date DESC
    ''';
    final result = await db.connection.execute(sql);
    return result.map((row) => PurchaseModel.fromJson(row.toColumnMap())).toList();
  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase, {int? userId}) async {
    final sql = '''
      INSERT INTO purchases (
        purchase_no, supplier_id, purchase_date, total_amount, status
      ) VALUES (
        @inv, @supId, @pDate, @total, @status
      ) RETURNING id, purchase_no as invoice_number, supplier_id, purchase_date, total_amount, status, created_at, updated_at;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'inv': purchase.invoiceNumber.trim(),
        'supId': purchase.supplierId?.toString(),
        'pDate': purchase.purchaseDate.toIso8601String(),
        'total': purchase.totalAmount,
        'status': purchase.paymentStatus,
      },
    );
    final row = result.first.toColumnMap();
    row['supplier_name'] = purchase.supplierName;
    row['payment_status'] = purchase.paymentStatus;
    return PurchaseModel.fromJson(row);
  }

  // ----------------------------------------------------
  // STOCK MOVEMENTS
  // ----------------------------------------------------
  Future<List<StockMovementModel>> getStockMovements({dynamic productId}) async {
    String sql = '''
      SELECT 
        sm.id,
        sm.product_id,
        COALESCE(p.name, 'Product') as product_name,
        COALESCE(p.sku, '') as product_code,
        sm.type as movement_type,
        COALESCE(sm.quantity, 0) as quantity,
        0 as previous_stock,
        COALESCE(sm.quantity, 0) as new_stock,
        sm.reference_no as reference_id,
        sm.remarks as notes,
        COALESCE(sm.created_at, CURRENT_TIMESTAMP) as created_at
      FROM stock_movements sm
      LEFT JOIN products p ON sm.product_id = p.id
    ''';
    if (productId != null) {
      sql += ' WHERE sm.product_id = @pid OR sm.product_id::text = @pidStr';
    }
    sql += ' ORDER BY sm.created_at DESC LIMIT 100';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: productId != null ? {'pid': productId.toString(), 'pidStr': productId.toString()} : {},
    );
    return result.map((row) => StockMovementModel.fromJson(row.toColumnMap())).toList();
  }

  Future<void> recordStockAdjustment({
    required dynamic productId,
    required double adjustmentQuantity,
    required String reason,
    int? userId,
  }) async {
    final prod = await getProductById(productId);
    if (prod == null) throw Exception('Product not found!');

    await db.connection.execute(
      Sql.named('''
        INSERT INTO stock_movements (
          id, product_id, type, quantity, reference_no, remarks, performed_by
        ) VALUES (
          @pid, 'ADJUSTMENT', @qty, 'ADJ-MANUAL', @notes, @uid
        )
      '''),
      parameters: {
        'pid': productId.toString(),
        'qty': adjustmentQuantity.toInt(),
        'notes': reason,
        'uid': userId?.toString() ?? 'admin',
      },
    );
  }

  // ----------------------------------------------------
  // REPORTS
  // ----------------------------------------------------
  Future<Map<String, dynamic>> getStockValueReport() async {
    final sql = '''
      SELECT 
        COUNT(id) as total_products,
        COALESCE(SUM(cost_price), 0) as total_cost_value,
        COALESCE(SUM(selling_price), 0) as total_retail_value
      FROM products
      WHERE status = 'active' OR status IS NULL;
    ''';
    final result = await db.connection.execute(sql);
    final row = result.first.toColumnMap();
    return {
      'totalProducts': row['total_products'] ?? 0,
      'totalCostValue': row['total_cost_value'] ?? 0.0,
      'totalRetailValue': row['total_retail_value'] ?? 0.0,
    };
  }

  Future<Map<String, dynamic>> getProfitLossReport() async {
    final sql = '''
      SELECT 
        COALESCE(SUM(cost_price), 0) as total_costs,
        COALESCE(SUM(selling_price), 0) as total_revenue
      FROM products;
    ''';
    final result = await db.connection.execute(sql);
    final row = result.first.toColumnMap();
    final rev = (row['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final cost = (row['total_costs'] as num?)?.toDouble() ?? 0.0;
    return {
      'totalRevenue': rev,
      'totalCosts': cost,
      'netProfit': rev - cost,
      'profitMarginPercentage': rev > 0 ? ((rev - cost) / rev) * 100 : 0.0,
    };
  }
}
