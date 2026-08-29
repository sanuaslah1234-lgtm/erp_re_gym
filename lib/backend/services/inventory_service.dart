import 'package:postgres/postgres.dart';

import '../database/postgres_service.dart';
import 'package:erp_software/core/models/inventory_model.dart';

class InventoryService {
  final PostgresService postgresService;
  InventoryService(this.postgresService);

  // =========================================================
  // CREATE
  // =========================================================

  Future<InventoryModel> createInventory({
    required String productId,
    required String warehouseId,
    int quantity = 0,
    int minimumStock = 10,
    int maximumStock = 1000,
    int reorderLevel = 20,
  }) async {
    final connection = postgresService.connection;

    // Resolve product code/name -> numeric product ID
    int numericProductId;
    final parsedPid = int.tryParse(productId);
    if (parsedPid != null) {
      numericProductId = parsedPid;
    } else {
      final prodResult = await connection.execute(
        Sql.named('SELECT id FROM products WHERE product_code = @code OR sku = @code OR LOWER(name) = LOWER(@code) LIMIT 1'),
        parameters: {'code': productId.trim()},
      );
      if (prodResult.isEmpty) throw Exception('Product "$productId" not found');
      numericProductId = prodResult.first[0] as int;
    }

    // Resolve warehouse code/name -> numeric warehouse ID
    int numericWarehouseId;
    final parsedWid = int.tryParse(warehouseId);
    if (parsedWid != null) {
      numericWarehouseId = parsedWid;
    } else {
      final whResult = await connection.execute(
        Sql.named('SELECT id FROM warehouses WHERE LOWER(name) = LOWER(@name) OR code = @code LIMIT 1'),
        parameters: {'name': warehouseId.trim(), 'code': warehouseId.trim()},
      );
      if (whResult.isEmpty) throw Exception('Warehouse "$warehouseId" not found');
      numericWarehouseId = whResult.first[0] as int;
    }

    // Check duplicate
    final existing = await connection.execute(
      Sql.named('SELECT id FROM inventory WHERE product_id = @productId AND warehouse_id = @warehouseId LIMIT 1'),
      parameters: {'productId': numericProductId, 'warehouseId': numericWarehouseId},
    );

    if (existing.isNotEmpty) {
      throw Exception('Inventory already exists for this product and warehouse');
    }

    final result = await connection.execute(
      Sql.named('''
        INSERT INTO inventory (
          product_id,
          warehouse_id,
          quantity,
          minimum_stock,
          maximum_stock,
          reorder_level
        )
        VALUES (
          @productId,
          @warehouseId,
          @quantity,
          @minimumStock,
          @maximumStock,
          @reorderLevel
        )
        RETURNING *
      '''),
      parameters: {
        'productId': numericProductId,
        'warehouseId': numericWarehouseId,
        'quantity': quantity,
        'minimumStock': minimumStock,
        'maximumStock': maximumStock,
        'reorderLevel': reorderLevel,
      },
    );

    return InventoryModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // =========================================================
  // GET ALL
  // =========================================================

  Future<List<InventoryModel>> getInventory({
    String? search,
    String? warehouseId,
    String? status,
    String sort = 'latest',
  }) async {
    final connection = postgresService.connection;

    final conditions = <String>[];
    final parameters = <String, dynamic>{};

    // SEARCH
    if (search != null && search.trim().isNotEmpty) {
      conditions.add('''
        (
          LOWER(p.name) LIKE LOWER(@search)
          OR LOWER(p.product_code) LIKE LOWER(@search)
          OR LOWER(p.barcode) LIKE LOWER(@search)
          OR LOWER(w.name) LIKE LOWER(@search)
        )
      ''');

      parameters['search'] = '%${search.trim()}%';
    }

    // WAREHOUSE
    if (warehouseId != null &&
        warehouseId.isNotEmpty) {
      conditions.add(
        'i.warehouse_id = @warehouseId',
      );

      parameters['warehouseId'] = warehouseId;
    }

    // STATUS
    if (status != null && status != 'All Statuses') {
      if (status == 'Out of Stock') {
        conditions.add('COALESCE(i.quantity, p.stock_quantity::int, 0) <= 0');
      } else if (status == 'Low Stock') {
        conditions.add('COALESCE(i.quantity, p.stock_quantity::int, 0) > 0 AND COALESCE(i.quantity, p.stock_quantity::int, 0) <= COALESCE(i.minimum_stock, 10)');
      } else if (status == 'In Stock') {
        conditions.add('COALESCE(i.quantity, p.stock_quantity::int, 0) > COALESCE(i.minimum_stock, 10)');
      }
    }

    String orderBy;

    switch (sort) {
      case 'a-z':
        orderBy = 'p.name ASC';
        break;

      case 'z-a':
        orderBy = 'p.name DESC';
        break;

      case 'latest':
      default:
        orderBy = 'p.created_at DESC';
    }

    final result = await connection.execute(
      Sql.named('''
        SELECT
          i.id,
          i.product_id,
          i.warehouse_id,
          i.quantity,
          i.minimum_stock,
          i.maximum_stock,
          COALESCE(i.id, 0) AS id,
          p.id AS product_id,
          COALESCE(i.warehouse_id, 0) AS warehouse_id,
          COALESCE(i.quantity, p.stock_quantity::int, 0) AS quantity,
          COALESCE(i.minimum_stock, 10) AS minimum_stock,
          COALESCE(i.maximum_stock, 1000) AS maximum_stock,
          COALESCE(i.reorder_level, 20) AS reorder_level,
          COALESCE(i.created_at, p.created_at) AS created_at,
          COALESCE(i.updated_at, p.updated_at) AS updated_at,

          p.name AS product_name,
          p.product_code AS sku,

          w.name AS warehouse_name

        FROM products p

        LEFT JOIN inventory i
          ON p.id = i.product_id

        LEFT JOIN warehouses w
          ON w.id = i.warehouse_id

        WHERE p.status = 'active'
        ${conditions.isNotEmpty ? 'AND ${conditions.join(' AND ')}' : ''}

        ORDER BY $orderBy
      '''),
      parameters: parameters,
    );

    return result
        .map(
          (row) => InventoryModel.fromMap(
            row.toColumnMap(),
          ),
        )
        .toList();
  }

  // =========================================================
  // GET ONE
  // =========================================================

  Future<InventoryModel?> getInventoryById(
    String id,
  ) async {
    final connection = postgresService.connection;

    final result = await connection.execute(
      Sql.named('''
        SELECT
          i.id,
          i.product_id,
          i.warehouse_id,
          i.quantity,
          i.minimum_stock,
          i.maximum_stock,
          i.reorder_level,
          i.created_at,
          i.updated_at,
          p.name AS product_name,
          p.product_code AS sku,
          w.name AS warehouse_name
        FROM inventory i
        LEFT JOIN products p ON p.id = i.product_id
        LEFT JOIN warehouses w ON w.id = i.warehouse_id
        WHERE i.id = @id
        LIMIT 1
      '''),
      parameters: {
        'id': int.tryParse(id.toString()) ?? id,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return InventoryModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<InventoryModel> updateInventory({
    required String id,
    String? productId,
    String? warehouseId,
    int? quantity,
    int? minimumStock,
    int? maximumStock,
    int? reorderLevel,
  }) async {
    final connection = postgresService.connection;

    // Resolve string IDs to int
    int? numericProductId;
    if (productId != null) {
      numericProductId = int.tryParse(productId);
      if (numericProductId == null) {
        final r = await connection.execute(
          Sql.named('SELECT id FROM products WHERE product_code = @code OR sku = @code OR LOWER(name) = LOWER(@code) LIMIT 1'),
          parameters: {'code': productId.trim()},
        );
        if (r.isNotEmpty) numericProductId = r.first[0] as int;
      }
    }
    int? numericWarehouseId;
    if (warehouseId != null) {
      numericWarehouseId = int.tryParse(warehouseId);
      if (numericWarehouseId == null) {
        final r = await connection.execute(
          Sql.named('SELECT id FROM warehouses WHERE LOWER(name) = LOWER(@name) OR code = @code LIMIT 1'),
          parameters: {'name': warehouseId.trim(), 'code': warehouseId.trim()},
        );
        if (r.isNotEmpty) numericWarehouseId = r.first[0] as int;
      }
    }

    final result = await connection.execute(
      Sql.named('''
        UPDATE inventory
        SET
          product_id = COALESCE(@productId, product_id),
          warehouse_id = COALESCE(@warehouseId, warehouse_id),
          quantity = COALESCE(@quantity, quantity),
          minimum_stock = COALESCE(@minimumStock, minimum_stock),
          maximum_stock = COALESCE(@maximumStock, maximum_stock),
          reorder_level = COALESCE(@reorderLevel, reorder_level),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': int.tryParse(id) ?? id,
        'productId': numericProductId,
        'warehouseId': numericWarehouseId,
        'quantity': quantity,
        'minimumStock': minimumStock,
        'maximumStock': maximumStock,
        'reorderLevel': reorderLevel,
      },
    );

    if (result.isEmpty) {
      throw Exception(
        'Inventory not found',
      );
    }

    return InventoryModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteInventory(
    String id,
  ) async {
    final connection = postgresService.connection;

    final result = await connection.execute(
      Sql.named('DELETE FROM inventory WHERE id = @id'),
      parameters: {'id': int.tryParse(id) ?? id},
    );

    if (result.affectedRows == 0) {
      throw Exception('Inventory not found');
    }
  }

  // =========================================================
  // UPDATE STOCK
  // =========================================================

  Future<InventoryModel> updateQuantity({
    required String id,
    required int quantity,
  }) async {
    if (quantity < 0) {
      throw Exception('Quantity cannot be negative');
    }

    final connection = postgresService.connection;

    final result = await connection.execute(
      Sql.named('''
        UPDATE inventory
        SET quantity = @quantity, updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': int.tryParse(id) ?? id,
        'quantity': quantity,
      },
    );

    if (result.isEmpty) {
      throw Exception(
        'Inventory not found',
      );
    }

    return InventoryModel.fromMap(
      result.first.toColumnMap(),
    );
  }
}
