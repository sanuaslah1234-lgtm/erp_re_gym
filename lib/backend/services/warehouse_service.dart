import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class WarehouseService {
  final PostgresService postgresService;

  WarehouseService(this.postgresService);

  // ==========================================================
  // CREATE WAREHOUSE
  // ==========================================================

  Future<Map<String, dynamic>> createWarehouse({
    required String name,
  }) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO warehouses (
          name
        )
        VALUES (
          @name
        )
        RETURNING
          id,
          name,
          created_at,
          updated_at
      '''),
      parameters: {
        'name': name,
      },
    );

    final row = result.first;

    return {
      'id': row[0].toString(),
      'name': row[1],
      'createdAt': row[2]?.toString(),
      'updatedAt': row[3]?.toString(),
    };
  }

  // ==========================================================
  // GET ALL WAREHOUSES
  // ==========================================================

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT
          id,
          name,
          city,
          created_at,
          updated_at
        FROM warehouses
        ORDER BY created_at DESC
      '''),
    );

    return result.map((row) {
      return {
        'id': row[0].toString(),
        'name': row[1],
        'createdAt': row[3]?.toString(),
        'updatedAt': row[4]?.toString(),
      };
    }).toList();
  }

  // ==========================================================
  // GET WAREHOUSE BY ID
  // ==========================================================

  Future<Map<String, dynamic>?> getWarehouseById(
    String id,
  ) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT
          id,
          name,
          created_at,
          updated_at
        FROM warehouses
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
      'createdAt': row[2]?.toString(),
      'updatedAt': row[3]?.toString(),
    };
  }

  // ==========================================================
  // UPDATE WAREHOUSE
  // ==========================================================

  Future<Map<String, dynamic>?> updateWarehouse({
    required String id,
    required String name,
  }) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        UPDATE warehouses
        SET
          name = @name,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id::uuid
        RETURNING
          id,
          name,
          created_at,
          updated_at
      '''),
      parameters: {
        'id': id,
        'name': name,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;

    return {
      'id': row[0].toString(),
      'name': row[1],
      'createdAt': row[2]?.toString(),
      'updatedAt': row[3]?.toString(),
    };
  }

  // ==========================================================
  // DELETE WAREHOUSE
  // ==========================================================

  Future<bool> deleteWarehouse(
    String id,
  ) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        DELETE FROM warehouses
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
