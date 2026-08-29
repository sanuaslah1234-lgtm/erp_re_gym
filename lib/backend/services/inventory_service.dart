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

    // Check duplicate
    final existing = await connection.execute(
      Sql.named('''
        SELECT id
        FROM inventory
        WHERE product_id = @productId
        AND warehouse_id = @warehouseId
        LIMIT 1
      '''),
      parameters: {
        'productId': productId,
        'warehouseId': warehouseId,
      },
    );

    if (existing.isNotEmpty) {
      throw Exception(
        'Inventory already exists for this product and warehouse',
      );
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
        'productId': productId,
        'warehouseId': warehouseId,
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
          OR LOWER(p.sku) LIKE LOWER(@search)
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
    if (status != null &&
        status != 'All Statuses') {
      if (status == 'Out of Stock') {
        conditions.add('i.quantity <= 0');
      } else if (status == 'Low Stock') {
        conditions.add(
          'i.quantity > 0 AND i.quantity <= i.minimum_stock',
        );
      } else if (status == 'In Stock') {
        conditions.add(
          'i.quantity > i.minimum_stock',
        );
      }
    }

    String whereClause = '';

    if (conditions.isNotEmpty) {
      whereClause =
          'WHERE ${conditions.join(' AND ')}';
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
        orderBy = 'i.created_at DESC';
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
          i.reorder_level,
          i.created_at,
          i.updated_at,

          p.name AS product_name,
          p.sku AS sku,

          w.name AS warehouse_name

        FROM inventory i

        INNER JOIN products p
          ON p.id = i.product_id

        INNER JOIN warehouses w
          ON w.id = i.warehouse_id

        $whereClause

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
          p.sku AS sku,

          w.name AS warehouse_name

        FROM inventory i

        INNER JOIN products p
          ON p.id = i.product_id

        INNER JOIN warehouses w
          ON w.id = i.warehouse_id

        WHERE i.id = @id

        LIMIT 1
      '''),
      parameters: {
        'id': id,
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
          product_id = COALESCE(
            @productId,
            product_id
          ),

          warehouse_id = COALESCE(
            @warehouseId,
            warehouse_id
          ),

          quantity = COALESCE(
            @quantity,
            quantity
          ),

          minimum_stock = COALESCE(
            @minimumStock,
            minimum_stock
          ),

          maximum_stock = COALESCE(
            @maximumStock,
            maximum_stock
          ),

          reorder_level = COALESCE(
            @reorderLevel,
            reorder_level
          ),

          updated_at = CURRENT_TIMESTAMP

        WHERE id = @id

        RETURNING *
      '''),
      parameters: {
        'id': id,
        'productId': productId,
        'warehouseId': warehouseId,
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
      Sql.named('''
        DELETE FROM inventory
        WHERE id = @id
      '''),
      parameters: {
        'id': id,
      },
    );

    if (result.affectedRows == 0) {
      throw Exception(
        'Inventory not found',
      );
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
      throw Exception(
        'Quantity cannot be negative',
      );
    }

    final connection = postgresService.connection;

    final result = await connection.execute(
      Sql.named('''
        UPDATE inventory

        SET
          quantity = @quantity,
          updated_at = CURRENT_TIMESTAMP

        WHERE id = @id

        RETURNING *
      '''),
      parameters: {
        'id': id,
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
