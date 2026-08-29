import 'package:erp_software/core/models/cashier/product_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class ProductRepository {
  final PostgresService db;

  ProductRepository(this.db);

  Future<List<ProductModel>> getAllProducts({String? search, int? categoryId}) async {
    String sql = '''
      SELECT p.*, c.name as category_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.is_active = true
    ''';

    final params = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      sql += ' AND (LOWER(p.name) LIKE LOWER(@search) OR LOWER(p.product_code) LIKE LOWER(@search) OR p.barcode LIKE @search)';
      params['search'] = '%${search.trim()}%';
    }

    if (categoryId != null && categoryId > 0) {
      sql += ' AND p.category_id = @catId';
      params['catId'] = categoryId;
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
      SELECT p.*, c.name as category_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.barcode = @barcode AND p.is_active = true
      LIMIT 1
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {'barcode': barcode.trim()},
    );

    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<ProductModel?> findById(int id) async {
    final sql = '''
      SELECT p.*, c.name as category_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.id = @id
      LIMIT 1
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return ProductModel.fromJson(result.first.toColumnMap());
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final result = await db.connection.execute('SELECT id, name FROM categories ORDER BY name ASC');
    return result.map((row) => {'id': row[0] as int, 'name': row[1] as String}).toList();
  }
}

