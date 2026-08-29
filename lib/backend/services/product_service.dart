import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class ProductService {
  final PostgresService postgresService;

  ProductService(this.postgresService);

  // ==========================================================
  // CREATE PRODUCT
  // ==========================================================

  Future<Map<String, dynamic>> createProduct({
    required String name,
    required String sku,
  }) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO products (
          name,
          sku
        )
        VALUES (
          @name,
          @sku
        )
        RETURNING
          id,
          name,
          sku,
          created_at,
          updated_at
      '''),
      parameters: {
        'name': name,
        'sku': sku,
      },
    );

    final row = result.first;

    return {
      'id': row[0].toString(),
      'name': row[1],
      'sku': row[2],
      'createdAt': row[3]?.toString(),
      'updatedAt': row[4]?.toString(),
    };
  }

  // ==========================================================
  // GET ALL PRODUCTS
  // ==========================================================

  Future<List<Map<String, dynamic>>> getProducts() async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT
          id,
          name,
          sku,
          created_at,
          updated_at
        FROM products
        ORDER BY created_at DESC
      '''),
    );

    return result.map((row) {
      return {
        'id': row[0].toString(),
        'name': row[1],
        'sku': row[2],
        'createdAt': row[3]?.toString(),
        'updatedAt': row[4]?.toString(),
      };
    }).toList();
  }

  // ==========================================================
  // GET PRODUCT BY ID
  // ==========================================================

  Future<Map<String, dynamic>?> getProductById(
    String id,
  ) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT
          id,
          name,
          sku,
          created_at,
          updated_at
        FROM products
        WHERE id = @id::uuid
      '''),
      parameters: {
        'id': id,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;

    return {
      'id': row[0].toString(),
      'name': row[1],
      'sku': row[2],
      'createdAt': row[3]?.toString(),
      'updatedAt': row[4]?.toString(),
    };
  }

  // ==========================================================
  // UPDATE PRODUCT
  // ==========================================================

  Future<Map<String, dynamic>?> updateProduct({
    required String id,
    required String name,
    required String sku,
  }) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        UPDATE products
        SET
          name = @name,
          sku = @sku,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id::uuid
        RETURNING
          id,
          name,
          sku,
          created_at,
          updated_at
      '''),
      parameters: {
        'id': id,
        'name': name,
        'sku': sku,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;

    return {
      'id': row[0].toString(),
      'name': row[1],
      'sku': row[2],
      'createdAt': row[3]?.toString(),
      'updatedAt': row[4]?.toString(),
    };
  }

  // ==========================================================
  // DELETE PRODUCT
  // ==========================================================

  Future<bool> deleteProduct(String id) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        DELETE FROM products
        WHERE id = @id::uuid
        RETURNING id
      '''),
      parameters: {
        'id': id,
      },
    );

    return result.isNotEmpty;
  }
}
