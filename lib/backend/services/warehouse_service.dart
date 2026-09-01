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
    final generatedCode = code != null && code.trim().isNotEmpty
        ? code.trim()
        : name.toUpperCase().replaceAll(RegExp(r'\s+'), '_').substring(0, name.length.clamp(0, 10));

    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO warehouses (id, name, code, address, phone, is_active)
        VALUES (@id, @name, @code, @address, @phone, true)
        RETURNING id, name, code, address, phone, is_active, created_at, updated_at
      '''),
      parameters: {
        'name': name.trim(),
        'code': generatedCode,
        'address': address?.trim(),
        'phone': phone?.trim(),
      },
    );

    return _rowToMap(result.first);
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

    return result.map((row) => _rowToMap(row)).toList();
  }

  // ==========================================================
  // GET WAREHOUSE BY ID
  // ==========================================================

  Future<Map<String, dynamic>?> getWarehouseById(String id) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT id, name, code, address, phone, is_active, created_at, updated_at
        FROM warehouses
        WHERE id = @id
        LIMIT 1
      '''),
      parameters: {'id': int.tryParse(id) ?? 0},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first);
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
            is_active = COALESCE(@isActive, is_active),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING id, name, code, address, phone, is_active, created_at, updated_at
      '''),
      parameters: {
        'id': int.tryParse(id) ?? 0,
        'name': name.trim(),
        'code': code?.trim(),
        'address': address?.trim(),
        'phone': phone?.trim(),
        'isActive': isActive,
      },
    );

    if (result.isEmpty) return null;
    return _rowToMap(result.first);
  }

  // ==========================================================
  // DELETE WAREHOUSE
  // ==========================================================

  Future<bool> deleteWarehouse(String id) async {
    final result = await postgresService.connection.execute(
      Sql.named('DELETE FROM warehouses WHERE id = @id'),
      parameters: {'id': int.tryParse(id) ?? 0},
    );

    return result.affectedRows > 0;
  }

  // ==========================================================
  // HELPER
  // ==========================================================

  Map<String, dynamic> _rowToMap(dynamic row) {
    final map = row.toColumnMap();
    final isActive = map['is_active'] == true;
    return {
      'id': map['id'].toString(),
      'name': map['name']?.toString() ?? '',
      'code': map['code']?.toString(),
      'address': map['address']?.toString(),
      'phone': map['phone']?.toString(),
      'is_active': isActive,
      'isActive': isActive,
      'status': isActive ? 'ACTIVE' : 'INACTIVE',
      'created_at': map['created_at']?.toString(),
      'updated_at': map['updated_at']?.toString(),
    };
  }
}
