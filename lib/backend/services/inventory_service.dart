import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

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

    // Resolve product ID
    dynamic resolvedProductId = productId.trim();
    final prodResult = await connection.execute(
      Sql.named('SELECT id FROM products WHERE id::text = @code OR product_code = @code OR sku = @code OR barcode = @code OR LOWER(name) = LOWER(@code) LIMIT 1'),
      parameters: {'code': productId.trim()},
    );
    if (prodResult.isNotEmpty) {
      resolvedProductId = prodResult.first[0];
    }

    // Resolve warehouse ID
    dynamic resolvedWarehouseId = warehouseId.trim();
    final whResult = await connection.execute(
      Sql.named('SELECT id FROM warehouses WHERE id::text = @code OR LOWER(name) = LOWER(@name) OR code = @code LIMIT 1'),
      parameters: {'name': warehouseId.trim(), 'code': warehouseId.trim()},
    );
    if (whResult.isNotEmpty) {
      resolvedWarehouseId = whResult.first[0];
    } else {
      final defaultWh = await connection.execute('SELECT id FROM warehouses LIMIT 1');
      if (defaultWh.isNotEmpty) {
        resolvedWarehouseId = defaultWh.first[0];
      }
    }

    // Check duplicate
    final existing = await connection.execute(
      Sql.named('SELECT id FROM inventory WHERE (product_id = @productId OR product_id::text = @productIdStr) AND (warehouse_id = @warehouseId OR warehouse_id::text = @warehouseIdStr) LIMIT 1'),
      parameters: {
        'productId': resolvedProductId,
        'productIdStr': resolvedProductId.toString(),
        'warehouseId': resolvedWarehouseId,
        'warehouseIdStr': resolvedWarehouseId.toString(),
      },
    );

    if (existing.isNotEmpty) {
      final existingId = existing.first[0].toString();
      return updateInventory(
        id: existingId,
        productId: resolvedProductId.toString(),
        warehouseId: resolvedWarehouseId.toString(),
        quantity: quantity,
        minimumStock: minimumStock,
        maximumStock: maximumStock,
        reorderLevel: reorderLevel,
      );
    }

    final generatedId = const Uuid().v4();
    Result result;
    try {
      result = await connection.execute(
        Sql.named('''
          INSERT INTO inventory (
            id,
            product_id,
            warehouse_id,
            quantity,
            minimum_stock,
            maximum_stock,
            reorder_level
          )
          VALUES (
            @id,
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
          'id': generatedId,
          'productId': resolvedProductId,
          'warehouseId': resolvedWarehouseId,
          'quantity': quantity,
          'minimumStock': minimumStock,
          'maximumStock': maximumStock,
          'reorderLevel': reorderLevel,
        },
      );
    } catch (_) {
      result = await connection.execute(
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
          'productId': resolvedProductId,
          'warehouseId': resolvedWarehouseId,
          'quantity': quantity,
          'minimumStock': minimumStock,
          'maximumStock': maximumStock,
          'reorderLevel': reorderLevel,
        },
      );
    }

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
          OR LOWER(COALESCE(p.product_code, '')) LIKE LOWER(@search)
          OR LOWER(COALESCE(p.sku, '')) LIKE LOWER(@search)
          OR LOWER(COALESCE(p.barcode, '')) LIKE LOWER(@search)
          OR LOWER(COALESCE(w.name, '')) LIKE LOWER(@search)
        )
      ''');

      parameters['search'] = '%${search.trim()}%';
    }

    // WAREHOUSE
    if (warehouseId != null && warehouseId.isNotEmpty && warehouseId != 'All Warehouses') {
      conditions.add(
        '(i.warehouse_id = @warehouseId OR i.warehouse_id::text = @warehouseIdStr OR w.id::text = @warehouseIdStr)',
      );

      parameters['warehouseId'] = warehouseId;
      parameters['warehouseIdStr'] = warehouseId;
    }

    // STATUS
    if (status != null && status.isNotEmpty && status != 'All Statuses') {
      if (status == 'Out of Stock') {
        conditions.add('COALESCE(i.quantity, 0) <= 0');
      } else if (status == 'Low Stock') {
        conditions.add('COALESCE(i.quantity, p.stock_quantity::int, 0) > 0 AND COALESCE(i.quantity, p.stock_quantity::int, 0) <= COALESCE(i.minimum_stock, 10)');
      } else if (status == 'In Stock' || status == 'Healthy Stock') {
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
          COALESCE(i.id::text, p.id::text) AS id,
          p.id::text AS product_id,
          COALESCE(i.warehouse_id::text, w.id::text, 'default') AS warehouse_id,
          COALESCE(i.quantity, p.stock_quantity::int, 0) AS quantity,
          COALESCE(i.minimum_stock, 10) AS minimum_stock,
          COALESCE(i.maximum_stock, 1000) AS maximum_stock,
          COALESCE(i.reorder_level, 20) AS reorder_level,
          COALESCE(i.created_at, p.created_at, CURRENT_TIMESTAMP) AS created_at,
          COALESCE(i.updated_at, p.updated_at, CURRENT_TIMESTAMP) AS updated_at,
          p.name AS product_name,
          COALESCE(p.product_code, p.sku, '') AS sku,
          COALESCE(w.name, 'Main Warehouse') AS warehouse_name
        FROM products p
        LEFT JOIN inventory i
          ON p.id::text = i.product_id::text
        LEFT JOIN warehouses w
          ON w.id::text = i.warehouse_id::text
        WHERE (p.is_active = true OR p.status IS NULL OR LOWER(p.status) = 'active')
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
          COALESCE(i.id::text, p.id::text) AS id,
          p.id::text AS product_id,
          COALESCE(i.warehouse_id::text, w.id::text, 'default') AS warehouse_id,
          COALESCE(i.quantity, p.stock_quantity::int, 0) AS quantity,
          COALESCE(i.minimum_stock, 10) AS minimum_stock,
          COALESCE(i.maximum_stock, 1000) AS maximum_stock,
          COALESCE(i.reorder_level, 20) AS reorder_level,
          COALESCE(i.created_at, p.created_at, CURRENT_TIMESTAMP) AS created_at,
          COALESCE(i.updated_at, p.updated_at, CURRENT_TIMESTAMP) AS updated_at,
          p.name AS product_name,
          COALESCE(p.product_code, p.sku, '') AS sku,
          COALESCE(w.name, 'Main Warehouse') AS warehouse_name
        FROM products p
        LEFT JOIN inventory i ON p.id::text = i.product_id::text
        LEFT JOIN warehouses w ON w.id::text = i.warehouse_id::text
        WHERE i.id::text = @id OR p.id::text = @id
        LIMIT 1
      '''),
      parameters: {
        'id': id.trim(),
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

    final result = await connection.execute(
      Sql.named('''
        UPDATE inventory
        SET
          quantity = COALESCE(@quantity, quantity),
          minimum_stock = COALESCE(@minimumStock, minimum_stock),
          maximum_stock = COALESCE(@maximumStock, maximum_stock),
          reorder_level = COALESCE(@reorderLevel, reorder_level),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id OR id::text = @idStr OR product_id = @id OR product_id::text = @idStr
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'idStr': id,
        'quantity': quantity,
        'minimumStock': minimumStock,
        'maximumStock': maximumStock,
        'reorderLevel': reorderLevel,
      },
    );

    if (quantity != null) {
      await connection.execute(
        Sql.named('''
          UPDATE products
          SET stock_quantity = @quantity, updated_at = CURRENT_TIMESTAMP
          WHERE id = @id OR id::text = @idStr
             OR id IN (SELECT product_id FROM inventory WHERE id = @id OR id::text = @idStr)
        '''),
        parameters: {'quantity': quantity, 'id': id, 'idStr': id},
      );
    }

    if (result.isEmpty) {
      final item = await getInventoryById(id);
      if (item != null) return item;
      throw Exception('Inventory not found');
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

    await connection.execute(
      Sql.named('DELETE FROM inventory WHERE id = @id OR id::text = @idStr'),
      parameters: {'id': id, 'idStr': id},
    );
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
        WHERE id = @id OR id::text = @idStr OR product_id = @id OR product_id::text = @idStr
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'idStr': id,
        'quantity': quantity,
      },
    );

    // Also sync with products.stock_quantity
    await connection.execute(
      Sql.named('UPDATE products SET stock_quantity = @quantity, updated_at = CURRENT_TIMESTAMP WHERE id = @id OR id::text = @idStr'),
      parameters: {'quantity': quantity, 'id': id, 'idStr': id},
    );

    if (result.isEmpty) {
      final item = await getInventoryById(id);
      if (item != null) return item;
      throw Exception('Inventory not found');
    }

    return InventoryModel.fromMap(
      result.first.toColumnMap(),
    );
  }
}
