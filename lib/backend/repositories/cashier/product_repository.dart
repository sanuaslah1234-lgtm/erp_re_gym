import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class ProductRepository {
  final PostgresService db;

  ProductRepository(this.db);

  Future<List<ProductModel>> getAllProducts({String? search, dynamic categoryId, dynamic brandId}) async {
    String sql = '''
      SELECT 
        p.*, 
        c.name as category_name,
        b.name as brand_name
      FROM products p
      LEFT JOIN categories c ON p.category_id::text = c.id::text
      LEFT JOIN brands b ON p.brand_id::text = b.id::text
      WHERE (p.is_active IS NULL OR p.is_active = true)
    ''';

    final params = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      sql += ' AND (LOWER(p.name) LIKE LOWER(@search) OR LOWER(COALESCE(p.product_code, \'\')) LIKE LOWER(@search) OR LOWER(COALESCE(p.sku, \'\')) LIKE LOWER(@search) OR LOWER(COALESCE(p.barcode, \'\')) LIKE LOWER(@search))';
      params['search'] = '%${search.trim()}%';
    }

    if (categoryId != null && categoryId.toString().trim().isNotEmpty && categoryId.toString() != '0') {
      sql += ' AND p.category_id::text = @catId';
      params['catId'] = categoryId.toString();
    }

    if (brandId != null && brandId.toString().trim().isNotEmpty && brandId.toString() != '0') {
      sql += ' AND (p.brand_id::text = @brandId OR LOWER(b.name) = LOWER(@brandId))';
      params['brandId'] = brandId.toString();
    }

    sql += ' ORDER BY p.name ASC';

    final result = await db.connection.execute(Sql.named(sql), parameters: params);

    return result.map((row) {
      final map = row.toColumnMap();
      return ProductModel.fromJson(map);
    }).toList();
  }

  Future<ProductModel?> findByBarcode(String barcode) async {
    final sql = '''
      SELECT 
        p.*, 
        c.name as category_name,
        b.name as brand_name
      FROM products p
      LEFT JOIN categories c ON p.category_id::text = c.id::text
      LEFT JOIN brands b ON p.brand_id::text = b.id::text
      WHERE (p.barcode = @barcode OR p.sku = @barcode OR p.product_code = @barcode) 
        AND (p.is_active IS NULL OR p.is_active = true)
      LIMIT 1
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {'barcode': barcode.trim()},
    );

    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<ProductModel?> findById(dynamic id) async {
    final sql = '''
      SELECT 
        p.*, 
        c.name as category_name,
        b.name as brand_name
      FROM products p
      LEFT JOIN categories c ON p.category_id::text = c.id::text
      LEFT JOIN brands b ON p.brand_id::text = b.id::text
      WHERE p.id::text = @id
      LIMIT 1
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {'id': id.toString()},
    );

    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final result = await db.connection.execute('SELECT id, name FROM categories ORDER BY name ASC');
    return result.map((row) => {'id': row[0], 'name': row[1].toString()}).toList();
  }

  Future<List<Map<String, dynamic>>> getBrands() async {
    final result = await db.connection.execute('SELECT id, name FROM brands ORDER BY name ASC');
    return result.map((row) => {'id': row[0], 'name': row[1].toString()}).toList();
  }
}
