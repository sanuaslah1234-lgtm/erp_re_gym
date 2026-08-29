import 'package:postgres/postgres.dart';

class ReportsRepository {
  final Connection connection;

  ReportsRepository(this.connection);

  // ============================================================
  // SALES SUMMARY (the 4 stat cards)
  // ============================================================

  Future<Map<String, dynamic>> getSalesSummary({
    required DateTime from,
    required DateTime to,
    String? customer,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT
          COALESCE(SUM(total) FILTER (WHERE status = 'completed'), 0)      AS total_revenue,
          COUNT(*) FILTER (WHERE status = 'completed')                     AS sales_orders,
          COALESCE(AVG(total) FILTER (WHERE status = 'completed'), 0)      AS average_value,
          COALESCE(SUM(discount) FILTER (WHERE status = 'completed'), 0)   AS total_discounts
        FROM sales_orders
        WHERE created_at::date BETWEEN @from AND @to
          AND (@customer::text IS NULL OR customer_name = @customer)
      '''),
      parameters: {
        'from': from.toIso8601String().split('T').first,
        'to': to.toIso8601String().split('T').first,
        'customer': (customer == null || customer.isEmpty || customer == 'All Customers')
            ? null
            : customer,
      },
    );

    final row = result.first;

    return {
      'total_revenue': double.tryParse(row[0].toString()) ?? 0,
      'sales_orders': row[1] as int,
      'average_value': double.tryParse(row[2].toString()) ?? 0,
      'total_discounts': double.tryParse(row[3].toString()) ?? 0,
    };
  }

  // ============================================================
  // DETAILED RECORDS TABLE
  // ============================================================

  Future<List<Map<String, dynamic>>> getSalesRecords({
    required DateTime from,
    required DateTime to,
    String? customer,
    String? search,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT
          id, order_number, customer_name, subtotal, discount, total, status, created_at
        FROM sales_orders
        WHERE created_at::date BETWEEN @from AND @to
          AND (@customer::text IS NULL OR customer_name = @customer)
          AND (
            @search::text IS NULL
            OR order_number ILIKE '%' || @search || '%'
            OR customer_name ILIKE '%' || @search || '%'
          )
        ORDER BY created_at DESC
      '''),
      parameters: {
        'from': from.toIso8601String().split('T').first,
        'to': to.toIso8601String().split('T').first,
        'customer': (customer == null || customer.isEmpty || customer == 'All Customers')
            ? null
            : customer,
        'search': (search == null || search.isEmpty) ? null : search,
      },
    );

    return result
        .map((row) => {
              'id': row[0],
              'order_number': row[1],
              'customer_name': row[2],
              'subtotal': row[3],
              'discount': row[4],
              'total': row[5],
              'status': row[6],
              'created_at': row[7]?.toString(),
            })
        .toList();
  }

  // ============================================================
  // DISTINCT CUSTOMERS (for the "Filter by Customer" dropdown)
  // ============================================================

  Future<List<String>> getDistinctCustomers() async {
    final result = await connection.execute('''
      SELECT DISTINCT customer_name
      FROM sales_orders
      ORDER BY customer_name
    ''');

    return result.map((row) => row[0].toString()).toList();
  }

  // ============================================================
  // PURCHASE SUMMARY (4 stat cards)
  // ============================================================

  Future<Map<String, dynamic>> getPurchaseSummary({
    required DateTime from,
    required DateTime to,
    String? supplier,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT
          COALESCE(SUM(total) FILTER (WHERE status = 'completed'), 0)   AS total_spend,
          COUNT(*) FILTER (WHERE status = 'completed')                  AS purchase_orders,
          COALESCE(AVG(total) FILTER (WHERE status = 'completed'), 0)   AS average_value,
          COALESCE(SUM(tax) FILTER (WHERE status = 'completed'), 0)     AS total_tax
        FROM purchases
        WHERE created_at::date BETWEEN @from AND @to
          AND (@supplier::text IS NULL OR supplier_name = @supplier)
      '''),
      parameters: {
        'from': from.toIso8601String().split('T').first,
        'to': to.toIso8601String().split('T').first,
        'supplier': (supplier == null || supplier.isEmpty || supplier == 'All Suppliers')
            ? null
            : supplier,
      },
    );

    final row = result.first;
    return {
      'total_spend': double.tryParse(row[0].toString()) ?? 0,
      'purchase_orders': row[1] as int,
      'average_value': double.tryParse(row[2].toString()) ?? 0,
      'total_tax': double.tryParse(row[3].toString()) ?? 0,
    };
  }

  // ============================================================
  // PURCHASE DETAILED RECORDS
  // ============================================================

  Future<List<Map<String, dynamic>>> getPurchaseRecords({
    required DateTime from,
    required DateTime to,
    String? supplier,
    String? search,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT id, po_number, supplier_name, subtotal, tax, total, status, created_at
        FROM purchases
        WHERE created_at::date BETWEEN @from AND @to
          AND (@supplier::text IS NULL OR supplier_name = @supplier)
          AND (
            @search::text IS NULL
            OR po_number ILIKE '%' || @search || '%'
            OR supplier_name ILIKE '%' || @search || '%'
          )
        ORDER BY created_at DESC
      '''),
      parameters: {
        'from': from.toIso8601String().split('T').first,
        'to': to.toIso8601String().split('T').first,
        'supplier': (supplier == null || supplier.isEmpty || supplier == 'All Suppliers')
            ? null
            : supplier,
        'search': (search == null || search.isEmpty) ? null : search,
      },
    );

    return result
        .map((row) => {
              'id': row[0],
              'po_number': row[1],
              'supplier_name': row[2],
              'subtotal': row[3],
              'tax': row[4],
              'total': row[5],
              'status': row[6],
              'created_at': row[7]?.toString(),
            })
        .toList();
  }

  // ============================================================
  // DISTINCT SUPPLIERS
  // ============================================================

  Future<List<String>> getDistinctSuppliers() async {
    final result = await connection.execute('''
      SELECT DISTINCT supplier_name FROM purchases ORDER BY supplier_name
    ''');
    return result.map((row) => row[0].toString()).toList();
  }

  // ============================================================
  // INVENTORY SUMMARY (4 stat cards) — snapshot, no date range
  // ============================================================

  Future<Map<String, dynamic>> getInventorySummary({String? category}) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT
          COALESCE(SUM(quantity_in_stock * unit_cost), 0)                       AS total_stock_value,
          COUNT(*)                                                              AS total_items,
          COUNT(*) FILTER (WHERE quantity_in_stock > 0 AND quantity_in_stock <= reorder_level) AS low_stock,
          COUNT(*) FILTER (WHERE quantity_in_stock = 0)                         AS out_of_stock
        FROM inventory_items
        WHERE (@category::text IS NULL OR category = @category)
      '''),
      parameters: {
        'category': (category == null || category.isEmpty || category == 'All Categories')
            ? null
            : category,
      },
    );

    final row = result.first;
    return {
      'total_stock_value': double.tryParse(row[0].toString()) ?? 0,
      'total_items': row[1] as int,
      'low_stock': row[2] as int,
      'out_of_stock': row[3] as int,
    };
  }

  // ============================================================
  // INVENTORY DETAILED RECORDS
  // ============================================================

  Future<List<Map<String, dynamic>>> getInventoryRecords({
    String? category,
    String? search,
  }) async {
    final result = await connection.execute(
      Sql.named('''
        SELECT id, sku, item_name, category, quantity_in_stock, unit_cost, reorder_level, updated_at
        FROM inventory_items
        WHERE (@category::text IS NULL OR category = @category)
          AND (
            @search::text IS NULL
            OR sku ILIKE '%' || @search || '%'
            OR item_name ILIKE '%' || @search || '%'
          )
        ORDER BY item_name ASC
      '''),
      parameters: {
        'category': (category == null || category.isEmpty || category == 'All Categories')
            ? null
            : category,
        'search': (search == null || search.isEmpty) ? null : search,
      },
    );

    return result
        .map((row) => {
              'id': row[0],
              'sku': row[1],
              'item_name': row[2],
              'category': row[3],
              'quantity_in_stock': row[4],
              'unit_cost': row[5],
              'reorder_level': row[6],
              'updated_at': row[7]?.toString(),
            })
        .toList();
  }

  // ============================================================
  // DISTINCT CATEGORIES
  // ============================================================

  Future<List<String>> getDistinctCategories() async {
    final result = await connection.execute('''
      SELECT DISTINCT category FROM inventory_items ORDER BY category
    ''');
    return result.map((row) => row[0].toString()).toList();
  }
}