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
    String? code,
    String? address,
    String? phone,
  }) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO warehouses (name, code, address, phone)
        VALUES (@name, @code, @address, @phone)
        RETURNING id, name, code, address, phone, is_active, created_at, updated_at
      '''),
      parameters: {
        'name': name,
        'code': code ?? name.toUpperCase().replaceAll(RegExp(r'\s+'), '_').substring(0, name.length.clamp(0, 10)),
        'address': address,
        'phone': phone,
      },
    );

    final row = result.first;
    return {
      'id': row[0].toString(),
      'name': row[1],
      'code': row[2]?.toString(),
      'address': row[3]?.toString(),
      'phone': row[4]?.toString(),
      'is_active': row[5],
      'createdAt': row[6]?.toString(),
      'updatedAt': row[7]?.toString(),
    };
  }

  // ==========================================================
  // GET ALL WAREHOUSES
  // ==========================================================

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT id, name, code, address, phone, is_active, created_at, updated_at
        FROM warehouses
        ORDER BY created_at DESC
      '''),
    );

    return result.map((row) {
      return {
        'id': row[0].toString(),
        'name': row[1],
        'code': row[2]?.toString(),
        'address': row[3]?.toString(),
        'phone': row[4]?.toString(),
        'is_active': row[5],
        'createdAt': row[6]?.toString(),
        'updatedAt': row[7]?.toString(),
      };
    }).toList();
  }

  // ==========================================================
  // GET WAREHOUSE BY ID
  // ==========================================================

  Future<Map<String, dynamic>?> getWarehouseById(String id) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT id, name, code, address, phone, is_active, created_at, updated_at
        FROM warehouses
        WHERE id = @id OR id::text = @idStr
      '''),
      parameters: {'id': id, 'idStr': id},
    );
    if (result.isEmpty) return null;
    final row = result.first;
    return {
      'id': row[0].toString(), 'name': row[1], 'code': row[2]?.toString(),
      'address': row[3]?.toString(), 'phone': row[4]?.toString(),
      'is_active': row[5], 'createdAt': row[6]?.toString(), 'updatedAt': row[7]?.toString(),
    };
  }

  // ==========================================================
  // UPDATE WAREHOUSE
  // ==========================================================

  Future<Map<String, dynamic>?> updateWarehouse({
    required String id,
    required String name,
    String? code,
    String? address,
    String? phone,
    bool? isActive,
  }) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        UPDATE warehouses
        SET name = @name, code = COALESCE(@code, code),
            address = @address, phone = @phone,
            is_active = COALESCE(@isActive, is_active),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = @id OR id::text = @idStr
        RETURNING id, name, code, address, phone, is_active, created_at, updated_at
      '''),
      parameters: {
        'id': id, 'idStr': id, 'name': name,
        'code': code, 'address': address, 'phone': phone,
        'isActive': isActive,
      },
    );

    if (result.isEmpty) return null;
    final row = result.first;
    return {
      'id': row[0].toString(), 'name': row[1], 'code': row[2]?.toString(),
      'address': row[3]?.toString(), 'phone': row[4]?.toString(),
      'is_active': row[5], 'createdAt': row[6]?.toString(), 'updatedAt': row[7]?.toString(),
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
        WHERE id = @id OR id::text = @idStr
        RETURNING id
      '''),
      parameters: {
        'id': id,
        'idStr': id,
      },
    );

    return result.isNotEmpty;
  }
}
