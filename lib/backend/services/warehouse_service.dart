import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

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
    final generatedId = const Uuid().v4();
    final generatedCode = code != null && code.trim().isNotEmpty
        ? code.trim()
        : name.toUpperCase().replaceAll(RegExp(r'\s+'), '_').substring(0, name.length.clamp(0, 10));

    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO warehouses (id, name, code, address, phone, status)
        VALUES (@id, @name, @code, @address, @phone, 'ACTIVE')
        RETURNING id, name, code, address, phone, status, created_at, updated_at
      '''),
      parameters: {
        'id': generatedId,
        'name': name.trim(),
        'code': generatedCode,
        'address': address?.trim(),
        'phone': phone?.trim(),
      },
    );

    final row = result.first;
    final statusStr = row[5]?.toString().toUpperCase() ?? 'ACTIVE';
    final isActive = statusStr == 'ACTIVE' || statusStr == 'TRUE';

    return {
      'id': row[0].toString(),
      'name': row[1]?.toString() ?? '',
      'code': row[2]?.toString(),
      'address': row[3]?.toString(),
      'phone': row[4]?.toString(),
      'status': statusStr,
      'is_active': isActive,
      'isActive': isActive,
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
        SELECT id, name, code, address, phone, COALESCE(status, 'ACTIVE') AS status, created_at, updated_at
        FROM warehouses
        ORDER BY created_at DESC
      '''),
    );

    return result.map((row) {
      final statusStr = row[5]?.toString().toUpperCase() ?? 'ACTIVE';
      final isActive = statusStr == 'ACTIVE' || statusStr == 'TRUE';
      return {
        'id': row[0].toString(),
        'name': row[1]?.toString() ?? '',
        'code': row[2]?.toString(),
        'address': row[3]?.toString(),
        'phone': row[4]?.toString(),
        'status': statusStr,
        'is_active': isActive,
        'isActive': isActive,
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
        SELECT id, name, code, address, phone, COALESCE(status, 'ACTIVE') AS status, created_at, updated_at
        FROM warehouses
        WHERE id::text = @idStr
        LIMIT 1
      '''),
      parameters: {'idStr': id.trim()},
    );
    if (result.isEmpty) return null;
    final row = result.first;
    final statusStr = row[5]?.toString().toUpperCase() ?? 'ACTIVE';
    final isActive = statusStr == 'ACTIVE' || statusStr == 'TRUE';
    return {
      'id': row[0].toString(),
      'name': row[1]?.toString() ?? '',
      'code': row[2]?.toString(),
      'address': row[3]?.toString(),
      'phone': row[4]?.toString(),
      'status': statusStr,
      'is_active': isActive,
      'isActive': isActive,
      'createdAt': row[6]?.toString(),
      'updatedAt': row[7]?.toString(),
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
    String? statusVal;
    if (isActive != null) {
      statusVal = isActive ? 'ACTIVE' : 'INACTIVE';
    }

    final result = await postgresService.connection.execute(
      Sql.named('''
        UPDATE warehouses
        SET name = @name,
            code = COALESCE(@code, code),
            address = @address,
            phone = @phone,
            status = COALESCE(@status, status),
            updated_at = CURRENT_TIMESTAMP
        WHERE id::text = @idStr
        RETURNING id, name, code, address, phone, COALESCE(status, 'ACTIVE') AS status, created_at, updated_at
      '''),
      parameters: {
        'idStr': id.trim(),
        'name': name.trim(),
        'code': code?.trim(),
        'address': address?.trim(),
        'phone': phone?.trim(),
        'status': statusVal,
      },
    );

    if (result.isEmpty) return null;
    final row = result.first;
    final statusStr = row[5]?.toString().toUpperCase() ?? 'ACTIVE';
    final activeBool = statusStr == 'ACTIVE' || statusStr == 'TRUE';
    return {
      'id': row[0].toString(),
      'name': row[1]?.toString() ?? '',
      'code': row[2]?.toString(),
      'address': row[3]?.toString(),
      'phone': row[4]?.toString(),
      'status': statusStr,
      'is_active': activeBool,
      'isActive': activeBool,
      'createdAt': row[6]?.toString(),
      'updatedAt': row[7]?.toString(),
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
        WHERE id::text = @idStr
        RETURNING id
      '''),
      parameters: {
        'idStr': id.trim(),
      },
    );

    return result.isNotEmpty;
  }
}
