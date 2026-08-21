import 'package:erp_software/backend/models/brand_model.dart';
import 'package:erp_software/backend/models/cashier/product_model.dart';
import 'package:erp_software/backend/models/category_model.dart';
import 'package:erp_software/backend/models/purchase_model.dart';
import 'package:erp_software/backend/models/stock_movement_model.dart';
import 'package:erp_software/backend/models/supplier_model.dart';
import 'package:erp_software/backend/models/unit_model.dart';
import 'package:erp_software/core/database/postgres_service.dart';
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
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE 1=1
    ''';

    final params = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      sql += ' AND (LOWER(p.name) LIKE LOWER(@search) OR LOWER(p.product_code) LIKE LOWER(@search) OR p.barcode LIKE @search OR LOWER(p.brand) LIKE LOWER(@search))';
      params['search'] = '%${search.trim()}%';
    }

    if (categoryId != null && categoryId > 0) {
      sql += ' AND p.category_id = @catId';
      params['catId'] = categoryId;
    }

    if (statusFilter == 'active') {
      sql += ' AND p.is_active = true';
    } else if (statusFilter == 'inactive') {
      sql += ' AND p.is_active = false';
    }

    if (lowStockOnly == true) {
      sql += ' AND p.stock_quantity <= p.minimum_stock AND p.is_active = true';
    }

    sql += ' ORDER BY p.name ASC';

    final result = await db.connection.execute(Sql.named(sql), parameters: params);

    return result.map((row) {
      return ProductModel.fromJson(row.toColumnMap());
    }).toList();
  }

  Future<ProductModel?> getProductById(int id) async {
    final sql = '''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.id = @id
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'id': id});
    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<ProductModel?> findByProductCode(String code) async {
    final sql = '''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.product_code = @code
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'code': code.trim()});
    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<ProductModel> createProduct(ProductModel p, {int? userId}) async {
    // Check duplicate product_code / SKU
    final existing = await findByProductCode(p.productCode);
    if (existing != null) {
      throw Exception('Product code / SKU "${p.productCode}" already exists!');
    }

    final initialStock = p.openingStock > 0 ? p.openingStock : p.stockQuantity;

    final sql = '''
      INSERT INTO products (
        product_code, barcode, name, category_id, supplier_id, brand, unit,
        purchase_price, selling_price, tax_percentage, opening_stock, stock_quantity,
        minimum_stock, image_url, description, is_active
      ) VALUES (
        @code, @barcode, @name, @catId, @supId, @brand, @unit,
        @pPrice, @sPrice, @tax, @opStock, @stock,
        @minStock, @img, @desc, @active
      ) RETURNING id;
    ''';

    final params = {
      'code': p.productCode.trim(),
      'barcode': p.barcode?.trim(),
      'name': p.name.trim(),
      'catId': p.categoryId,
      'supId': p.supplierId,
      'brand': p.brand?.trim(),
      'unit': p.unit,
      'pPrice': p.purchasePrice,
      'sPrice': p.sellingPrice,
      'tax': p.taxPercentage,
      'opStock': p.openingStock,
      'stock': initialStock,
      'minStock': p.minimumStock,
      'img': p.imageUrl?.trim(),
      'desc': p.description?.trim(),
      'active': p.isActive,
    };

    final result = await db.connection.execute(Sql.named(sql), parameters: params);
    final newId = result.first[0] as int;

    // Audit initial opening stock movement if initialStock > 0
    if (initialStock > 0) {
      await db.connection.execute(
        Sql.named('''
          INSERT INTO stock_movements (
            product_id, movement_type, quantity, previous_stock, new_stock, reference_id, notes, created_by
          ) VALUES (
            @pid, 'OPENING', @qty, 0, @qty, 'INIT-001', 'Initial Opening Stock', @uid
          );
        '''),
        parameters: {
          'pid': newId,
          'qty': initialStock,
          'uid': userId,
        },
      );
    }

    return (await getProductById(newId))!;
  }

  Future<ProductModel> updateProduct(int id, ProductModel p) async {
    final sql = '''
      UPDATE products SET
        product_code = @code,
        barcode = @barcode,
        name = @name,
        category_id = @catId,
        supplier_id = @supId,
        brand = @brand,
        unit = @unit,
        purchase_price = @pPrice,
        selling_price = @sPrice,
        tax_percentage = @tax,
        minimum_stock = @minStock,
        image_url = @img,
        description = @desc,
        is_active = @active,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id;
    ''';

    final params = {
      'id': id,
      'code': p.productCode.trim(),
      'barcode': p.barcode?.trim(),
      'name': p.name.trim(),
      'catId': p.categoryId,
      'supId': p.supplierId,
      'brand': p.brand?.trim(),
      'unit': p.unit,
      'pPrice': p.purchasePrice,
      'sPrice': p.sellingPrice,
      'tax': p.taxPercentage,
      'minStock': p.minimumStock,
      'img': p.imageUrl?.trim(),
      'desc': p.description?.trim(),
      'active': p.isActive,
    };

    await db.connection.execute(Sql.named(sql), parameters: params);
    return (await getProductById(id))!;
  }

  Future<bool> deactivateProduct(int id) async {
    // Check if product has sales/purchase history before full delete
    final history = await db.connection.execute(
      Sql.named('SELECT COUNT(*) FROM pos_order_items WHERE product_id = @id'),
      parameters: {'id': id},
    );
    final count = history.first[0] as int;

    if (count > 0) {
      // Deactivate instead of hard delete
      await db.connection.execute(
        Sql.named('UPDATE products SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = @id'),
        parameters: {'id': id},
      );
      return false; // Soft deactivated
    } else {
      await db.connection.execute(
        Sql.named('DELETE FROM products WHERE id = @id'),
        parameters: {'id': id},
      );
      return true; // Hard deleted
    }
  }

  // ----------------------------------------------------
  // CATEGORIES CRUD
  // ----------------------------------------------------
  Future<List<CategoryModel>> getAllCategories() async {
    final sql = '''
      SELECT c.*, COUNT(p.id) as product_count
      FROM categories c
      LEFT JOIN products p ON p.category_id = c.id
      GROUP BY c.id
      ORDER BY c.name ASC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) {
      final map = row.toColumnMap();
      map['product_count'] = (map['product_count'] ?? 0) as int;
      return CategoryModel.fromJson(map);
    }).toList();
  }

  Future<CategoryModel> createCategory(CategoryModel cat) async {
    final sql = '''
      INSERT INTO categories (name, description, status)
      VALUES (@name, @desc, @status)
      RETURNING id;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'name': cat.name.trim(),
        'desc': cat.description?.trim(),
        'status': cat.status,
      },
    );
    final newId = result.first[0] as int;
    return CategoryModel(
      id: newId,
      name: cat.name.trim(),
      description: cat.description?.trim(),
      status: cat.status,
    );
  }

  Future<CategoryModel> updateCategory(int id, CategoryModel cat) async {
    final sql = '''
      UPDATE categories SET
        name = @name,
        description = @desc,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id,
        'name': cat.name.trim(),
        'desc': cat.description?.trim(),
        'status': cat.status,
      },
    );
    return CategoryModel(id: id, name: cat.name.trim(), description: cat.description?.trim(), status: cat.status);
  }

  Future<void> deleteCategory(int id) async {
    await db.connection.execute(
      Sql.named('DELETE FROM categories WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  // ----------------------------------------------------
  // BRANDS CRUD
  // ----------------------------------------------------
  Future<List<BrandModel>> getAllBrands() async {
    final sql = '''
      SELECT b.*, COUNT(p.id) as product_count
      FROM brands b
      LEFT JOIN products p ON LOWER(p.brand) = LOWER(b.name)
      GROUP BY b.id
      ORDER BY b.name ASC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) {
      final map = row.toColumnMap();
      map['product_count'] = (map['product_count'] ?? 0) as int;
      return BrandModel.fromJson(map);
    }).toList();
  }

  Future<BrandModel> createBrand(BrandModel brand) async {
    final sql = '''
      INSERT INTO brands (name, description, status)
      VALUES (@name, @desc, @status)
      RETURNING id;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'name': brand.name.trim(),
        'desc': brand.description?.trim(),
        'status': brand.status,
      },
    );
    final newId = result.first[0] as int;
    return BrandModel(
      id: newId,
      name: brand.name.trim(),
      description: brand.description?.trim(),
      status: brand.status,
    );
  }

  Future<BrandModel> updateBrand(int id, BrandModel brand) async {
    final sql = '''
      UPDATE brands SET
        name = @name,
        description = @desc,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id,
        'name': brand.name.trim(),
        'desc': brand.description?.trim(),
        'status': brand.status,
      },
    );
    return BrandModel(
      id: id,
      name: brand.name.trim(),
      description: brand.description?.trim(),
      status: brand.status,
    );
  }

  Future<void> deleteBrand(int id) async {
    await db.connection.execute(
      Sql.named('DELETE FROM brands WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  // ----------------------------------------------------
  // UNITS CRUD
  // ----------------------------------------------------
  Future<List<UnitModel>> getAllUnits() async {
    final sql = '''
      SELECT u.*, COUNT(p.id) as product_count
      FROM units u
      LEFT JOIN products p ON LOWER(p.unit) = LOWER(u.name) OR LOWER(p.unit) = LOWER(u.short_symbol)
      GROUP BY u.id
      ORDER BY u.name ASC
    ''';

    final result = await db.connection.execute(sql);
    return result.map((row) {
      final map = row.toColumnMap();
      map['product_count'] = (map['product_count'] ?? 0) as int;
      return UnitModel.fromJson(map);
    }).toList();
  }

  Future<UnitModel> createUnit(UnitModel unit) async {
    final sql = '''
      INSERT INTO units (name, short_symbol, status)
      VALUES (@name, @symbol, @status)
      RETURNING id;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'name': unit.name.trim(),
        'symbol': unit.shortSymbol.trim(),
        'status': unit.status,
      },
    );
    final newId = result.first[0] as int;
    return UnitModel(
      id: newId,
      name: unit.name.trim(),
      shortSymbol: unit.shortSymbol.trim(),
      status: unit.status,
    );
  }

  Future<UnitModel> updateUnit(int id, UnitModel unit) async {
    final sql = '''
      UPDATE units SET
        name = @name,
        short_symbol = @symbol,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id,
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

  Future<void> deleteUnit(int id) async {
    await db.connection.execute(
      Sql.named('DELETE FROM units WHERE id = @id'),
      parameters: {'id': id},
    );
  }


  // ----------------------------------------------------
  // SUPPLIERS CRUD
  // ----------------------------------------------------
  Future<List<SupplierModel>> getAllSuppliers() async {
    final sql = 'SELECT * FROM suppliers ORDER BY name ASC';
    final result = await db.connection.execute(sql);
    return result.map((row) => SupplierModel.fromJson(row.toColumnMap())).toList();
  }

  Future<SupplierModel> createSupplier(SupplierModel sup) async {
    final sql = '''
      INSERT INTO suppliers (supplier_code, name, phone, email, address, gst_vat_number, status)
      VALUES (@code, @name, @phone, @email, @address, @gst, @status)
      RETURNING id;
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'code': sup.supplierCode.trim(),
        'name': sup.name.trim(),
        'phone': sup.phone?.trim(),
        'email': sup.email?.trim(),
        'address': sup.address?.trim(),
        'gst': sup.gstVatNumber?.trim(),
        'status': sup.status,
      },
    );
    final newId = result.first[0] as int;
    return SupplierModel(
      id: newId,
      supplierCode: sup.supplierCode.trim(),
      name: sup.name.trim(),
      phone: sup.phone?.trim(),
      email: sup.email?.trim(),
      address: sup.address?.trim(),
      gstVatNumber: sup.gstVatNumber?.trim(),
      status: sup.status,
    );
  }

  Future<SupplierModel> updateSupplier(int id, SupplierModel sup) async {
    final sql = '''
      UPDATE suppliers SET
        supplier_code = @code,
        name = @name,
        phone = @phone,
        email = @email,
        address = @address,
        gst_vat_number = @gst,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': id,
        'code': sup.supplierCode.trim(),
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
  // PURCHASES (STOCK IN TRANSACTION)
  // ----------------------------------------------------
  Future<PurchaseModel> createPurchase(PurchaseModel p, {int? userId}) async {
    return await db.connection.runTx((tx) async {
      // 1. Insert purchase invoice header
      final purchaseRes = await tx.execute(
        Sql.named('''
          INSERT INTO purchases (
            invoice_number, supplier_id, purchase_date, subtotal, tax_amount, discount_amount, total_amount, payment_status, created_by
          ) VALUES (
            @inv, @supId, @pDate, @subtotal, @tax, @disc, @total, @status, @uid
          ) RETURNING id;
        '''),
        parameters: {
          'inv': p.invoiceNumber.trim(),
          'supId': p.supplierId,
          'pDate': p.purchaseDate,
          'subtotal': p.subtotal,
          'tax': p.taxAmount,
          'disc': p.discountAmount,
          'total': p.totalAmount,
          'status': p.paymentStatus,
          'uid': userId,
        },
      );
      final purchaseId = purchaseRes.first[0] as int;

      // 2. Process items & update stock
      for (final item in p.items) {
        await tx.execute(
          Sql.named('''
            INSERT INTO purchase_items (
              purchase_id, product_id, quantity, purchase_price, tax_amount, discount_amount, total_amount
            ) VALUES (
              @purId, @pid, @qty, @price, @tax, @disc, @total
            );
          '''),
          parameters: {
            'purId': purchaseId,
            'pid': item.productId,
            'qty': item.quantity,
            'price': item.purchasePrice,
            'tax': item.taxAmount,
            'disc': item.discountAmount,
            'total': item.totalAmount,
          },
        );

        // Fetch current stock
        final prodRes = await tx.execute(
          Sql.named('SELECT stock_quantity FROM products WHERE id = @pid FOR UPDATE'),
          parameters: {'pid': item.productId},
        );
        final currentStock = prodRes.first[0] is num ? (prodRes.first[0] as num).toDouble() : (double.tryParse(prodRes.first[0].toString()) ?? 0.0);
        final newStock = currentStock + item.quantity;

        // Update product stock
        await tx.execute(
          Sql.named('UPDATE products SET stock_quantity = @newStock, updated_at = CURRENT_TIMESTAMP WHERE id = @pid'),
          parameters: {'newStock': newStock, 'pid': item.productId},
        );

        // Record stock movement (PURCHASE_IN)
        await tx.execute(
          Sql.named('''
            INSERT INTO stock_movements (
              product_id, movement_type, quantity, previous_stock, new_stock, reference_id, notes, created_by
            ) VALUES (
              @pid, 'PURCHASE_IN', @qty, @prev, @newStock, @ref, 'Stock IN via Purchase Invoice', @uid
            );
          '''),
          parameters: {
            'pid': item.productId,
            'qty': item.quantity,
            'prev': currentStock,
            'newStock': newStock,
            'ref': p.invoiceNumber,
            'uid': userId,
          },
        );
      }

      return PurchaseModel(
        id: purchaseId,
        invoiceNumber: p.invoiceNumber,
        supplierId: p.supplierId,
        purchaseDate: p.purchaseDate,
        subtotal: p.subtotal,
        taxAmount: p.taxAmount,
        discountAmount: p.discountAmount,
        totalAmount: p.totalAmount,
        paymentStatus: p.paymentStatus,
        createdBy: userId,
        items: p.items,
      );
    });
  }

  Future<List<PurchaseModel>> getAllPurchases() async {
    final sql = '''
      SELECT p.*, s.name as supplier_name
      FROM purchases p
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      ORDER BY p.created_at DESC
    ''';
    final result = await db.connection.execute(sql);
    return result.map((row) => PurchaseModel.fromJson(row.toColumnMap())).toList();
  }

  // ----------------------------------------------------
  // STOCK ADJUSTMENTS / DAMAGE (STOCK OUT / IN)
  // ----------------------------------------------------
  Future<StockMovementModel> recordStockAdjustment({
    required int productId,
    required String movementType, // DAMAGE_OUT, ADJUSTMENT_IN, ADJUSTMENT_OUT
    required double quantity,
    required String reason,
    int? userId,
  }) async {
    return await db.connection.runTx((tx) async {
      final prodRes = await tx.execute(
        Sql.named('SELECT stock_quantity, product_code, name FROM products WHERE id = @pid FOR UPDATE'),
        parameters: {'pid': productId},
      );

      if (prodRes.isEmpty) throw Exception('Product ID $productId not found!');

      final row = prodRes.first.toColumnMap();
      final currentStock = row['stock_quantity'] is num ? (row['stock_quantity'] as num).toDouble() : (double.tryParse(row['stock_quantity'].toString()) ?? 0.0);
      final pCode = row['product_code'].toString();
      final pName = row['name'].toString();

      double newStock = currentStock;
      if (movementType == 'DAMAGE_OUT' || movementType == 'ADJUSTMENT_OUT') {
        if (quantity > currentStock) {
          throw Exception('Adjustment quantity ($quantity) cannot exceed available stock ($currentStock)!');
        }
        newStock = currentStock - quantity;
      } else {
        newStock = currentStock + quantity;
      }

      // Update product stock
      await tx.execute(
        Sql.named('UPDATE products SET stock_quantity = @newStock, updated_at = CURRENT_TIMESTAMP WHERE id = @pid'),
        parameters: {'newStock': newStock, 'pid': productId},
      );

      // Insert stock movement
      final refId = '${movementType.substring(0, 3)}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final smRes = await tx.execute(
        Sql.named('''
          INSERT INTO stock_movements (
            product_id, movement_type, quantity, previous_stock, new_stock, reference_id, notes, created_by
          ) VALUES (
            @pid, @type, @qty, @prev, @newStock, @ref, @notes, @uid
          ) RETURNING id;
        '''),
        parameters: {
          'pid': productId,
          'type': movementType,
          'qty': quantity,
          'prev': currentStock,
          'newStock': newStock,
          'ref': refId,
          'notes': reason,
          'uid': userId,
        },
      );

      final smId = smRes.first[0] as int;

      return StockMovementModel(
        id: smId,
        productId: productId,
        productName: pName,
        productCode: pCode,
        movementType: movementType,
        quantity: quantity,
        previousStock: currentStock,
        newStock: newStock,
        referenceId: refId,
        notes: reason,
        createdBy: userId,
        createdAt: DateTime.now(),
      );
    });
  }

  // ----------------------------------------------------
  // STOCK AUDIT LOG & REPORTS
  // ----------------------------------------------------
  Future<List<StockMovementModel>> getStockMovements({int? productId}) async {
    String sql = '''
      SELECT sm.*, p.name as product_name, p.product_code
      FROM stock_movements sm
      JOIN products p ON sm.product_id = p.id
    ''';

    final params = <String, dynamic>{};
    if (productId != null && productId > 0) {
      sql += ' WHERE sm.product_id = @pid';
      params['pid'] = productId;
    }

    sql += ' ORDER BY sm.created_at DESC';

    final result = await db.connection.execute(Sql.named(sql), parameters: params);
    return result.map((row) => StockMovementModel.fromJson(row.toColumnMap())).toList();
  }

  Future<Map<String, dynamic>> getStockValueReport() async {
    final sql = '''
      SELECT
        COALESCE(SUM(stock_quantity * purchase_price), 0) as total_stock_value,
        COALESCE(SUM(stock_quantity * selling_price), 0) as total_retail_value,
        COUNT(*) as total_products,
        SUM(CASE WHEN stock_quantity <= minimum_stock THEN 1 ELSE 0 END) as low_stock_count
      FROM products
      WHERE is_active = true
    ''';

    final res = await db.connection.execute(sql);
    final row = res.first.toColumnMap();

    double parseD(dynamic v) => v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '0') ?? 0.0);
    int parseI(dynamic v) => v is num ? v.toInt() : (int.tryParse(v?.toString() ?? '0') ?? 0);

    return {
      'totalStockValue': parseD(row['total_stock_value']),
      'totalRetailValue': parseD(row['total_retail_value']),
      'totalProducts': parseI(row['total_products']),
      'lowStockCount': parseI(row['low_stock_count']),
    };
  }

  Future<Map<String, dynamic>> getProfitLossReport() async {
    final salesSql = 'SELECT COALESCE(SUM(grand_total), 0) as total_sales FROM pos_orders WHERE order_status = \'paid\'';
    final purchaseSql = 'SELECT COALESCE(SUM(total_amount), 0) as total_purchases FROM purchases';
    final expenseSql = 'SELECT COALESCE(SUM(amount), 0) as total_expenses FROM expenses';

    final salesRes = await db.connection.execute(salesSql);
    final purRes = await db.connection.execute(purchaseSql);
    final expRes = await db.connection.execute(expenseSql);

    double parseD(dynamic v) => v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '0') ?? 0.0);

    final totalSales = parseD(salesRes.first[0]);
    final totalPurchases = parseD(purRes.first[0]);
    final totalExpenses = parseD(expRes.first[0]);
    final netProfit = totalSales - (totalPurchases + totalExpenses);

    return {
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalExpenses': totalExpenses,
      'netProfit': netProfit,
    };
  }
}
