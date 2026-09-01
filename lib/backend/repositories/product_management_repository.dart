import 'package:erp_software/core/models/brand_model.dart';
import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/core/models/category_model.dart';
import 'package:erp_software/core/models/purchase_model.dart';
import 'package:erp_software/core/models/stock_movement_model.dart';
import 'package:erp_software/core/models/supplier_model.dart';
import 'package:erp_software/core/models/unit_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

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
        COALESCE(p.sku, p.product_code, '') as product_code,
        COALESCE(p.barcode, p.sku, '') as barcode,
        p.category_id,
        c.name as category_name,
        p.brand_id,
        b.name as brand,
        p.unit_id,
        COALESCE(u.name, p.unit, 'pcs') as unit,
        COALESCE(p.cost_price, p.purchase_price, 0) as purchase_price,
        COALESCE(p.selling_price, 0) as selling_price,
        COALESCE(p.tax_percentage, 0) as tax_percentage,
        0 as opening_stock,
        COALESCE(p.stock_quantity, 0) as stock_quantity,
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
        COALESCE(p.sku, p.product_code, '') as product_code,
        COALESCE(p.barcode, p.sku, '') as barcode,
        p.category_id,
        c.name as category_name,
        p.brand_id,
        b.name as brand,
        p.unit_id,
        COALESCE(u.name, p.unit, 'pcs') as unit,
        COALESCE(p.cost_price, p.purchase_price, 0) as purchase_price,
        COALESCE(p.selling_price, 0) as selling_price,
        COALESCE(p.tax_percentage, 0) as tax_percentage,
        0 as opening_stock,
        COALESCE(p.stock_quantity, 0) as stock_quantity,
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
        COALESCE(p.sku, p.product_code, '') as product_code,
        COALESCE(p.barcode, p.sku, '') as barcode,
        p.category_id,
        c.name as category_name,
        p.brand_id,
        b.name as brand,
        p.unit_id,
        COALESCE(u.name, p.unit, 'pcs') as unit,
        COALESCE(p.cost_price, p.purchase_price, 0) as purchase_price,
        COALESCE(p.selling_price, 0) as selling_price,
        COALESCE(p.tax_percentage, 0) as tax_percentage,
        0 as opening_stock,
        COALESCE(p.stock_quantity, 0) as stock_quantity,
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
      WHERE LOWER(COALESCE(p.sku, p.product_code, '')) = LOWER(@code)
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'code': code.trim()});
    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<ProductModel> createProduct(ProductModel p, {dynamic userId}) async {
    String code = p.productCode.trim();
    if (code.isEmpty) {
      code = 'PRD-${DateTime.now().millisecondsSinceEpoch % 100000}';
    }

    final existing = await findByProductCode(code);
    if (existing != null) {
      code = '$code-${DateTime.now().millisecondsSinceEpoch % 1000}';
    }

    // Resolve brand name -> brand_id
    dynamic brandId;
    if (p.brand != null && p.brand!.isNotEmpty) {
      final brandResult = await db.connection.execute(
        Sql.named('SELECT id FROM brands WHERE LOWER(name) = LOWER(@name) LIMIT 1'),
        parameters: {'name': p.brand!.trim()},
      );
      if (brandResult.isNotEmpty) {
        brandId = int.tryParse(brandResult.first[0].toString()) ?? brandResult.first[0];
      } else {
        // Auto-create brand
        final brandGenId = const Uuid().v4();
        Result newBrand;
        try {
          newBrand = await db.connection.execute(
            Sql.named("INSERT INTO brands (id, name, status) VALUES (@id, @name, 'active') RETURNING id"),
            parameters: {'id': brandGenId, 'name': p.brand!.trim()},
          );
        } catch (_) {
          newBrand = await db.connection.execute(
            Sql.named("INSERT INTO brands (name, status) VALUES (@name, 'active') RETURNING id"),
            parameters: {'name': p.brand!.trim()},
          );
        }
        brandId = int.tryParse(newBrand.first[0].toString()) ?? newBrand.first[0];
      }
    }

    // Resolve unit name -> unit_id
    dynamic unitId;
    if (p.unit.isNotEmpty) {
      final unitResult = await db.connection.execute(
        Sql.named('SELECT id FROM units WHERE LOWER(name) = LOWER(@name) OR LOWER(code) = LOWER(@name) LIMIT 1'),
        parameters: {'name': p.unit.trim()},
      );
      if (unitResult.isNotEmpty) {
        unitId = int.tryParse(unitResult.first[0].toString()) ?? unitResult.first[0];
      } else {
        // Auto-create unit
        final unitGenId = const Uuid().v4();
        Result newUnit;
        try {
          newUnit = await db.connection.execute(
            Sql.named("INSERT INTO units (id, name, code, status) VALUES (@id, @name, @name, 'active') RETURNING id"),
            parameters: {'id': unitGenId, 'name': p.unit.trim()},
          );
        } catch (_) {
          newUnit = await db.connection.execute(
            Sql.named("INSERT INTO units (name, code, status) VALUES (@name, @name, 'active') RETURNING id"),
            parameters: {'name': p.unit.trim()},
          );
        }
        unitId = int.tryParse(newUnit.first[0].toString()) ?? newUnit.first[0];
      }
    }

    final catId = p.categoryId != null ? (int.tryParse(p.categoryId.toString()) ?? p.categoryId) : null;

    final params = {
      'name': p.name.trim(),
      'code': code,
      'sku': p.barcode?.trim().isNotEmpty == true ? p.barcode!.trim() : code,
      'barcode': p.barcode?.trim().isNotEmpty == true ? p.barcode!.trim() : code,
      'catId': catId,
      'brandId': brandId,
      'unitId': unitId,
      'unit': p.unit.trim().isNotEmpty ? p.unit.trim() : 'pcs',
      'pPrice': p.purchasePrice,
      'sPrice': p.sellingPrice,
      'tax': p.taxPercentage,
      'stock': p.stockQuantity.toInt(),
      'img': p.imageUrl?.trim(),
      'desc': p.description?.trim(),
      'isActive': p.isActive,
      'status': p.isActive ? 'active' : 'inactive',
    };

    final generatedProdId = const Uuid().v4();
    Result result;
    try {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO products (
            id, name, product_code, sku, barcode, category_id, brand_id, unit_id, unit,
            cost_price, purchase_price, selling_price, tax_percentage,
            stock_quantity, description, image, is_active, status
          ) VALUES (
            @id, @name, @code, @sku, @barcode, @catId, @brandId, @unitId, @unit,
            @pPrice, @pPrice, @sPrice, @tax,
            @stock, @desc, @img, @isActive, @status
          ) RETURNING id;
        '''),
        parameters: {
          ...params,
          'id': generatedProdId,
        },
      );
    } catch (_) {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO products (
            name, product_code, sku, barcode, category_id, brand_id, unit_id, unit,
            cost_price, purchase_price, selling_price, tax_percentage,
            stock_quantity, description, image, is_active, status
          ) VALUES (
            @name, @code, @sku, @barcode, @catId, @brandId, @unitId, @unit,
            @pPrice, @pPrice, @sPrice, @tax,
            @stock, @desc, @img, @isActive, @status
          ) RETURNING id;
        '''),
        parameters: params,
      );
    }
    final newId = int.tryParse(result.first[0].toString()) ?? result.first[0];

    // Auto-create inventory record in the first available warehouse
    try {
      final whResult = await db.connection.execute(
        Sql.named('SELECT id FROM warehouses WHERE (status IS NULL OR UPPER(status) = \'ACTIVE\') ORDER BY created_at ASC LIMIT 1'),
      );
      if (whResult.isNotEmpty) {
        final whId = int.tryParse(whResult.first[0].toString()) ?? whResult.first[0];
        final stockQty = p.stockQuantity.toInt();
        await db.connection.execute(
          Sql.named('''
            INSERT INTO inventory (product_id, warehouse_id, quantity, minimum_stock, maximum_stock, reorder_level)
            VALUES (@pid, @wid, @qty, @min, @max, @reorder)
            ON CONFLICT (product_id, warehouse_id) DO UPDATE SET quantity = @qty
          '''),
          parameters: {'pid': newId, 'wid': whId, 'qty': stockQty, 'min': 10, 'max': 1000, 'reorder': 20},
        );
      }
    } catch (_) {}

    return (await getProductById(newId))!;
  }

  Future<ProductModel> updateProduct(dynamic id, ProductModel p) async {
    final intId = int.tryParse(id.toString()) ?? id;

    // Resolve brand name -> brand_id
    dynamic brandId;
    if (p.brand != null && p.brand!.isNotEmpty) {
      final brandResult = await db.connection.execute(
        Sql.named('SELECT id FROM brands WHERE LOWER(name) = LOWER(@name) LIMIT 1'),
        parameters: {'name': p.brand!.trim()},
      );
      if (brandResult.isNotEmpty) {
        brandId = int.tryParse(brandResult.first[0].toString()) ?? brandResult.first[0];
      } else {
        final newBrand = await db.connection.execute(
          Sql.named("INSERT INTO brands (name, status) VALUES (@name, 'active') RETURNING id"),
          parameters: {'name': p.brand!.trim()},
        );
        brandId = int.tryParse(newBrand.first[0].toString()) ?? newBrand.first[0];
      }
    }

    // Resolve unit name -> unit_id
    dynamic unitId;
    if (p.unit.isNotEmpty) {
      final unitResult = await db.connection.execute(
        Sql.named('SELECT id FROM units WHERE LOWER(name) = LOWER(@name) OR LOWER(code) = LOWER(@name) LIMIT 1'),
        parameters: {'name': p.unit.trim()},
      );
      if (unitResult.isNotEmpty) {
        unitId = int.tryParse(unitResult.first[0].toString()) ?? unitResult.first[0];
      } else {
        final newUnit = await db.connection.execute(
          Sql.named("INSERT INTO units (name, code, status) VALUES (@name, @name, 'active') RETURNING id"),
          parameters: {'name': p.unit.trim()},
        );
        unitId = int.tryParse(newUnit.first[0].toString()) ?? newUnit.first[0];
      }
    }

    final catId = p.categoryId != null ? (int.tryParse(p.categoryId.toString()) ?? p.categoryId) : null;

    final sql = '''
      UPDATE products SET
        product_code = @code,
        sku = @sku,
        barcode = @barcode,
        name = @name,
        category_id = @catId,
        brand_id = @brandId,
        unit_id = @unitId,
        unit = @unit,
        cost_price = @pPrice,
        purchase_price = @pPrice,
        selling_price = @sPrice,
        tax_percentage = @tax,
        stock_quantity = @stock,
        image = @img,
        description = @desc,
        is_active = @isActive,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id OR id::text = @idStr;
    ''';

    final params = {
      'id': intId,
      'idStr': id.toString(),
      'code': p.productCode.trim(),
      'sku': p.barcode?.trim().isNotEmpty == true ? p.barcode!.trim() : p.productCode.trim(),
      'barcode': p.barcode?.trim().isNotEmpty == true ? p.barcode!.trim() : p.productCode.trim(),
      'name': p.name.trim(),
      'catId': catId,
      'brandId': brandId,
      'unitId': unitId,
      'unit': p.unit.trim().isNotEmpty ? p.unit.trim() : 'pcs',
      'pPrice': p.purchasePrice,
      'sPrice': p.sellingPrice,
      'tax': p.taxPercentage,
      'stock': p.stockQuantity.toInt(),
      'img': p.imageUrl?.trim(),
      'desc': p.description?.trim(),
      'isActive': p.isActive,
      'status': p.isActive ? 'active' : 'inactive',
    };

    await db.connection.execute(Sql.named(sql), parameters: params);
    final updated = await getProductById(id);
    if (updated == null) throw Exception('Product not found after update');
    return updated;
  }

  Future<bool> deactivateProduct(dynamic id) async {
    final intId = int.tryParse(id.toString()) ?? id;
    try {
      final res = await db.connection.execute(
        Sql.named("DELETE FROM products WHERE id = @id OR id::text = @idStr"),
        parameters: {'id': intId, 'idStr': id.toString()},
      );
      if (res.affectedRows > 0) return true;
    } catch (_) {
      // Soft-delete if product is referenced in sales / inventory
      await db.connection.execute(
        Sql.named("UPDATE products SET status = 'inactive', is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = @id OR id::text = @idStr"),
        parameters: {'id': intId, 'idStr': id.toString()},
      );
    }
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
    // Check for duplicate
    final existing = await db.connection.execute(
      Sql.named('SELECT id FROM categories WHERE LOWER(name) = LOWER(@name) LIMIT 1'),
      parameters: {'name': cat.name.trim()},
    );
    if (existing.isNotEmpty) {
      throw Exception('Category "${cat.name}" already exists!');
    }

    final generatedId = const Uuid().v4();
    final slugOrCode = (cat.description != null && cat.description!.isNotEmpty)
        ? cat.description!.trim()
        : cat.name.trim().toLowerCase().replaceAll(' ', '-');

    Result result;
    try {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO categories (id, name, code, description, status)
          VALUES (@id, @name, @code, @desc, @status)
          RETURNING id, name, description, status, created_at, updated_at;
        '''),
        parameters: {
          'id': generatedId,
          'name': cat.name.trim(),
          'code': slugOrCode,
          'desc': cat.description?.trim(),
          'status': cat.status,
        },
      );
    } catch (_) {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO categories (name, code, description, status)
          VALUES (@name, @code, @desc, @status)
          RETURNING id, name, description, status, created_at, updated_at;
        '''),
        parameters: {
          'name': cat.name.trim(),
          'code': slugOrCode,
          'desc': cat.description?.trim(),
          'status': cat.status,
        },
      );
    }
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
        'id': int.tryParse(id.toString()) ?? id,
        'idStr': id.toString(),
        'name': cat.name.trim(),
        'desc': cat.description?.trim(),
        'status': cat.status,
      },
    );
    return CategoryModel(id: id, name: cat.name.trim(), description: cat.description?.trim(), status: cat.status);
  }

  Future<void> deleteCategory(dynamic id) async {
    final pid = int.tryParse(id.toString()) ?? id;
    await db.connection.execute(
      Sql.named('UPDATE products SET category_id = NULL WHERE category_id = @id OR category_id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
    );
    await db.connection.execute(
      Sql.named('DELETE FROM categories WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
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
    // Check for duplicate
    final existing = await db.connection.execute(
      Sql.named('SELECT id FROM brands WHERE LOWER(name) = LOWER(@name) LIMIT 1'),
      parameters: {'name': brand.name.trim()},
    );
    if (existing.isNotEmpty) {
      throw Exception('Brand "${brand.name}" already exists!');
    }

    final generatedId = const Uuid().v4();
    Result result;
    try {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO brands (id, name, description, status)
          VALUES (@id, @name, @desc, @status)
          RETURNING id, name, description, status, created_at, updated_at;
        '''),
        parameters: {
          'id': generatedId,
          'name': brand.name.trim(),
          'desc': brand.description?.trim(),
          'status': brand.status,
        },
      );
    } catch (_) {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO brands (name, description, status)
          VALUES (@name, @desc, @status)
          RETURNING id, name, description, status, created_at, updated_at;
        '''),
        parameters: {
          'name': brand.name.trim(),
          'desc': brand.description?.trim(),
          'status': brand.status,
        },
      );
    }
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
        'id': int.tryParse(id.toString()) ?? id,
        'idStr': id.toString(),
        'name': brand.name.trim(),
        'desc': brand.description?.trim(),
        'status': brand.status,
      },
    );
    return BrandModel(id: id, name: brand.name.trim(), description: brand.description?.trim(), status: brand.status);
  }

  Future<void> deleteBrand(dynamic id) async {
    final pid = int.tryParse(id.toString()) ?? id;
    await db.connection.execute(
      Sql.named('UPDATE products SET brand_id = NULL WHERE brand_id = @id OR brand_id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
    );
    await db.connection.execute(
      Sql.named('DELETE FROM brands WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
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
    // Check for duplicate name
    final existing = await db.connection.execute(
      Sql.named('SELECT id FROM units WHERE LOWER(name) = LOWER(@name) LIMIT 1'),
      parameters: {'name': unit.name.trim()},
    );
    if (existing.isNotEmpty) {
      throw Exception('Unit "${unit.name}" already exists!');
    }

    final generatedId = const Uuid().v4();
    Result result;
    try {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO units (id, name, code, status)
          VALUES (@id, @name, @symbol, @status)
          RETURNING id, name, code as short_symbol, status, created_at, updated_at;
        '''),
        parameters: {
          'id': generatedId,
          'name': unit.name.trim(),
          'symbol': unit.shortSymbol.trim(),
          'status': unit.status,
        },
      );
    } catch (_) {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO units (name, code, status)
          VALUES (@name, @symbol, @status)
          RETURNING id, name, code as short_symbol, status, created_at, updated_at;
        '''),
        parameters: {
          'name': unit.name.trim(),
          'symbol': unit.shortSymbol.trim(),
          'status': unit.status,
        },
      );
    }
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
        'id': int.tryParse(id.toString()) ?? id,
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
    final pid = int.tryParse(id.toString()) ?? id;
    await db.connection.execute(
      Sql.named('UPDATE products SET unit_id = NULL WHERE unit_id = @id OR unit_id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
    );
    await db.connection.execute(
      Sql.named('DELETE FROM units WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
    );
  }

  // ----------------------------------------------------
  // SUPPLIERS CRUD
  // ----------------------------------------------------
  Future<List<SupplierModel>> getAllSuppliers() async {
    final sql = '''
      SELECT 
        s.id,
        COALESCE(s.company_name, s.name, '') as name,
        COALESCE(s.supplier_code, 'SUP-' || s.id) as supplier_code,
        COALESCE(s.company_name, s.name, '') as company_name,
        s.phone,
        s.email,
        s.address,
        COALESCE(s.gst_vat_number, s.tax_number) as gst_vat_number,
        COALESCE(s.status, 'active') as status,
        COALESCE(s.created_at, CURRENT_TIMESTAMP) as created_at,
        COALESCE(s.updated_at, CURRENT_TIMESTAMP) as updated_at
      FROM suppliers s
      ORDER BY COALESCE(s.company_name, s.name) ASC
    ''';
    final result = await db.connection.execute(sql);
    return result.map((row) => SupplierModel.fromJson(row.toColumnMap())).toList();
  }

  Future<SupplierModel> createSupplier(SupplierModel sup) async {
    // Try with supplier_code first, fallback without
    Result result;
    try {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO suppliers (supplier_code, name, company_name, contact_person, phone, email, address, gst_vat_number, tax_number, status)
          VALUES (@code, @name, @companyName, @name, @phone, @email, @address, @gst, @gst, @status)
          RETURNING id, COALESCE(company_name, name) as name, COALESCE(supplier_code, 'SUP-' || id) as supplier_code, COALESCE(company_name, name) as company_name, phone, email, address, COALESCE(gst_vat_number, tax_number) as gst_vat_number, status, created_at, updated_at;
        '''),
        parameters: {
          'code': sup.supplierCode.trim().isNotEmpty ? sup.supplierCode.trim() : 'SUP-${DateTime.now().millisecondsSinceEpoch % 100000}',
          'name': sup.name.trim(),
          'companyName': (sup.companyName ?? sup.name).trim(),
          'phone': sup.phone?.trim(),
          'email': sup.email?.trim(),
          'address': sup.address?.trim(),
          'gst': sup.gstVatNumber?.trim(),
          'status': sup.status,
        },
      );
    } catch (_) {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO suppliers (name, company_name, contact_person, phone, email, address, gst_vat_number, tax_number, status)
          VALUES (@name, @companyName, @name, @phone, @email, @address, @gst, @gst, @status)
          RETURNING id, COALESCE(company_name, name) as name, COALESCE(supplier_code, 'SUP-' || id) as supplier_code, COALESCE(company_name, name) as company_name, phone, email, address, COALESCE(gst_vat_number, tax_number) as gst_vat_number, status, created_at, updated_at;
        '''),
        parameters: {
          'name': sup.name.trim(),
          'companyName': (sup.companyName ?? sup.name).trim(),
          'phone': sup.phone?.trim(),
          'email': sup.email?.trim(),
          'address': sup.address?.trim(),
          'gst': sup.gstVatNumber?.trim(),
          'status': sup.status,
        },
      );
    }
    return SupplierModel.fromJson(result.first.toColumnMap());
  }

  Future<SupplierModel> updateSupplier(dynamic id, SupplierModel sup) async {
    final intId = int.tryParse(id.toString()) ?? id;
    final sql = '''
      UPDATE suppliers SET
        company_name = @companyName,
        name = @name,
        phone = @phone,
        email = @email,
        address = @address,
        gst_vat_number = @gst,
        tax_number = @gst,
        status = @status,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id OR id::text = @idStr;
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': intId,
        'idStr': id.toString(),
        'companyName': (sup.companyName ?? sup.name).trim(),
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
      companyName: (sup.companyName ?? sup.name).trim(),
      phone: sup.phone?.trim(),
      email: sup.email?.trim(),
      address: sup.address?.trim(),
      gstVatNumber: sup.gstVatNumber?.trim(),
      status: sup.status,
    );
  }

  Future<void> deleteSupplier(dynamic id) async {
    final pid = int.tryParse(id.toString()) ?? id;
    await db.connection.execute(
      Sql.named('UPDATE purchases SET supplier_id = NULL WHERE supplier_id = @id OR supplier_id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
    );
    await db.connection.execute(
      Sql.named('DELETE FROM suppliers WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': pid, 'idStr': id.toString()},
    );
  }

  // ----------------------------------------------------
  // PURCHASES CRUD
  // ----------------------------------------------------
  Future<List<PurchaseModel>> getAllPurchases() async {
    final sql = '''
      SELECT 
        pu.id,
        COALESCE(pu.po_number, '') as invoice_number,
        pu.supplier_id,
        COALESCE(s.company_name, s.name, pu.supplier_name, 'General Supplier') as supplier_name,
        COALESCE(pu.received_date, pu.created_at, CURRENT_TIMESTAMP) as purchase_date,
        COALESCE(pu.total_amount, 0) as total_amount,
        0 as paid_amount,
        0 as due_amount,
        COALESCE(pu.status, 'paid') as payment_status,
        COALESCE(pu.status, 'received') as status,
        COALESCE(pu.notes, '') as notes,
        COALESCE(pu.created_at, CURRENT_TIMESTAMP) as created_at,
        COALESCE(pu.updated_at, CURRENT_TIMESTAMP) as updated_at
      FROM purchases pu
      LEFT JOIN suppliers s ON pu.supplier_id = s.id
      ORDER BY pu.created_at DESC
    ''';
    final result = await db.connection.execute(sql);
    return result.map((row) => PurchaseModel.fromJson(row.toColumnMap())).toList();
  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase, {dynamic userId}) async {
    final params = {
      'poNumber': purchase.invoiceNumber.trim(),
      'supplierId': purchase.supplierId != null ? (int.tryParse(purchase.supplierId.toString()) ?? purchase.supplierId) : null,
      'supplierName': purchase.supplierName,
      'total': purchase.totalAmount,
      'status': purchase.paymentStatus,
      'receivedDate': purchase.purchaseDate.toIso8601String(),
    };

    final generatedId = const Uuid().v4();
    Result result;
    try {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO purchases (
            id, po_number, supplier_id, supplier_name, total_amount, status, received_date
          ) VALUES (
            @id, @poNumber, @supplierId, @supplierName, @total, @status, @receivedDate
          ) RETURNING id, po_number as invoice_number, supplier_id, supplier_name, total_amount, status, created_at, updated_at;
        '''),
        parameters: {
          ...params,
          'id': generatedId,
        },
      );
    } catch (_) {
      result = await db.connection.execute(
        Sql.named('''
          INSERT INTO purchases (
            po_number, supplier_id, supplier_name, total_amount, status, received_date
          ) VALUES (
            @poNumber, @supplierId, @supplierName, @total, @status, @receivedDate
          ) RETURNING id, po_number as invoice_number, supplier_id, supplier_name, total_amount, status, created_at, updated_at;
        '''),
        parameters: params,
      );
    }
    final row = result.first.toColumnMap();
    row['payment_status'] = purchase.paymentStatus;
    row['purchase_date'] = purchase.purchaseDate.toIso8601String();
    return PurchaseModel.fromJson(row);
  }

  Future<PurchaseModel?> getPurchaseById(dynamic id) async {
    final intId = int.tryParse(id.toString()) ?? id;
    final sql = '''
      SELECT 
        pu.id,
        COALESCE(pu.po_number, '') as invoice_number,
        pu.supplier_id,
        COALESCE(s.company_name, s.name, pu.supplier_name, 'General Supplier') as supplier_name,
        COALESCE(pu.received_date, pu.created_at, CURRENT_TIMESTAMP) as purchase_date,
        COALESCE(pu.total_amount, 0) as total_amount,
        0 as paid_amount,
        0 as due_amount,
        COALESCE(pu.status, 'paid') as payment_status,
        COALESCE(pu.status, 'received') as status,
        '' as notes,
        COALESCE(pu.created_at, CURRENT_TIMESTAMP) as created_at,
        COALESCE(pu.updated_at, CURRENT_TIMESTAMP) as updated_at
      FROM purchases pu
      LEFT JOIN suppliers s ON pu.supplier_id = s.id
      WHERE pu.id = @id
      LIMIT 1
    ''';
    final result = await db.connection.execute(Sql.named(sql), parameters: {'id': intId});
    if (result.isEmpty) return null;
    return PurchaseModel.fromJson(result.first.toColumnMap());
  }

  Future<PurchaseModel> updatePurchase(dynamic id, PurchaseModel purchase) async {
    final intId = int.tryParse(id.toString()) ?? id;
    final sql = '''
      UPDATE purchases SET
        po_number = @poNumber,
        supplier_id = @supplierId,
        supplier_name = @supplierName,
        total_amount = @total,
        status = @status,
        received_date = @receivedDate,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id
    ''';

    await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'id': intId,
        'poNumber': purchase.invoiceNumber.trim(),
        'supplierId': purchase.supplierId != null ? (int.tryParse(purchase.supplierId.toString()) ?? purchase.supplierId) : null,
        'supplierName': purchase.supplierName,
        'total': purchase.totalAmount,
        'status': purchase.paymentStatus,
        'receivedDate': purchase.purchaseDate.toIso8601String(),
      },
    );
    return (await getPurchaseById(id))!;
  }

  Future<void> deletePurchase(dynamic id) async {
    final intId = int.tryParse(id.toString()) ?? id;
    // Delete purchase items first (may not exist)
    try {
      await db.connection.execute(
        Sql.named('DELETE FROM purchase_items WHERE purchase_id = @id'),
        parameters: {'id': intId},
      );
    } catch (_) {}
    // Delete the purchase
    await db.connection.execute(
      Sql.named('DELETE FROM purchases WHERE id = @id'),
      parameters: {'id': intId},
    );
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
      parameters: productId != null ? {'pid': int.tryParse(productId.toString()) ?? productId, 'pidStr': productId.toString()} : {},
    );
    return result.map((row) => StockMovementModel.fromJson(row.toColumnMap())).toList();
  }

  Future<Map<String, dynamic>> recordStockAdjustment({
    required dynamic productId,
    required double adjustmentQuantity,
    required String reason,
    String? movementType,
    dynamic userId,
  }) async {
    final prod = await getProductById(productId);
    if (prod == null) throw Exception('Product not found!');

    final type = movementType ?? 'ADJUSTMENT';
    final pid = int.tryParse(productId.toString()) ?? productId;

    // Determine new stock quantity
    final currentStock = prod.stockQuantity;
    final newStock = (type.contains('OUT'))
        ? (currentStock - adjustmentQuantity).clamp(0.0, 999999.0)
        : currentStock + adjustmentQuantity;

    final generatedSmId = const Uuid().v4();
    try {
      await db.connection.execute(
        Sql.named('''
          INSERT INTO stock_movements (
            id, product_id, type, quantity, reference_no, remarks, performed_by
          ) VALUES (
            @id, @pid, @type, @qty, 'ADJ-MANUAL', @notes, @uid
          )
        '''),
        parameters: {
          'id': generatedSmId,
          'pid': pid,
          'type': type,
          'qty': adjustmentQuantity.toInt(),
          'notes': reason,
          'uid': userId?.toString() ?? 'admin',
        },
      );
    } catch (_) {
      await db.connection.execute(
        Sql.named('''
          INSERT INTO stock_movements (
            product_id, type, quantity, reference_no, remarks, performed_by
          ) VALUES (
            @pid, @type, @qty, 'ADJ-MANUAL', @notes, @uid
          )
        '''),
        parameters: {
          'pid': pid,
          'type': type,
          'qty': adjustmentQuantity.toInt(),
          'notes': reason,
          'uid': userId?.toString() ?? 'admin',
        },
      );
    }

    // Update product stock quantity
    await db.connection.execute(
      Sql.named('UPDATE products SET stock_quantity = @qty, updated_at = CURRENT_TIMESTAMP WHERE id = @id OR id::text = @idStr'),
      parameters: {'qty': newStock.toInt(), 'id': pid, 'idStr': pid.toString()},
    );

    return {
      'product_id': pid,
      'product_name': prod.name,
      'product_code': prod.productCode,
      'type': type,
      'quantity': adjustmentQuantity.toInt(),
      'previous_stock': currentStock.toInt(),
      'new_stock': newStock.toInt(),
      'notes': reason,
    };
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
    final rev = double.tryParse(row['total_revenue']?.toString() ?? '0') ?? 0.0;
    final cost = double.tryParse(row['total_costs']?.toString() ?? '0') ?? 0.0;
    return {
      'totalRevenue': rev,
      'totalCosts': cost,
      'netProfit': rev - cost,
      'profitMarginPercentage': rev > 0 ? ((rev - cost) / rev) * 100 : 0.0,
    };
  }
}
