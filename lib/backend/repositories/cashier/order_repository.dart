import 'package:erp_software/core/models/cashier/order_item_model.dart';
import 'package:erp_software/core/models/cashier/payment_model.dart';
import 'package:erp_software/core/models/cashier/pos_order_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:postgres/postgres.dart';

class OrderRepository {
  final PostgresService db;

  OrderRepository(this.db);

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? defaultVal;
  }

  /// Generates the next sequential order number (e.g. POS-20260814-0001)
  Future<String> generateOrderNumber() async {
    final now = DateTime.now();
    final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final prefix = "POS-$dateStr-";

    final result = await db.connection.execute(
      Sql.named("SELECT COUNT(*) FROM pos_orders WHERE order_number LIKE @prefix"),
      parameters: {'prefix': '$prefix%'},
    );

    final count = (result.first[0] as num).toInt() + 1;
    return "$prefix${count.toString().padLeft(4, '0')}";
  }

  /// Creates a POS order inside an atomic PostgreSQL transaction (`runTx`)
  Future<PosOrderModel> createOrderInTx({
    required int cashierId,
    int? customerId,
    required double subtotal,
    required double discountAmount,
    required double taxAmount,
    required double grandTotal,
    required double amountReceived,
    required double changeAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> itemsData,
    required List<Map<String, dynamic>> paymentsData,
    bool allowNegativeStock = false,
  }) async {
    final orderNumber = await generateOrderNumber();

    late PosOrderModel createdOrder;

    await db.connection.runTx((session) async {
      // 1. Validate product stock inside transaction
      for (final item in itemsData) {
        final prodId = item['product_id'];
        final requestedQty = _parseDouble(item['quantity'], 1.0);

        final prodRes = await session.execute(
          Sql.named("SELECT name, stock_quantity FROM products WHERE id::text = @idStr FOR UPDATE"),
          parameters: {'idStr': prodId.toString()},
        );

        if (prodRes.isEmpty) {
          throw ApiException('Product ID $prodId not found', statusCode: 400);
        }

        final currentStock = _parseDouble(prodRes.first[1]);
        final prodName = prodRes.first[0].toString();

        if (!allowNegativeStock && currentStock < requestedQty) {
          throw ApiException('Insufficient stock for "$prodName". Available: $currentStock, Requested: $requestedQty', statusCode: 400);
        }
      }

      // 2. Insert pos_orders header
      final orderRes = await session.execute(
        Sql.named('''
          INSERT INTO pos_orders (
            order_number, customer_id, cashier_id, subtotal, discount_amount,
            tax_amount, grand_total, payment_status, order_status, amount_received, change_amount
          )
          VALUES (
            @orderNumber, @customerId, @cashierId, @subtotal, @discountAmount,
            @taxAmount, @grandTotal, 'paid', 'paid', @amountReceived, @changeAmount
          )
          RETURNING id, created_at, updated_at
        '''),
        parameters: {
          'orderNumber': orderNumber,
          'customerId': customerId,
          'cashierId': cashierId,
          'subtotal': subtotal,
          'discountAmount': discountAmount,
          'taxAmount': taxAmount,
          'grandTotal': grandTotal,
          'amountReceived': amountReceived,
          'changeAmount': changeAmount,
        },
      );

      final orderId = orderRes.first[0];
      final createdAt = DateTime.parse(orderRes.first[1].toString());
      final updatedAt = DateTime.parse(orderRes.first[2].toString());

      // 3. Insert order items & decrease product stock
      final insertedItems = <OrderItemModel>[];
      for (final item in itemsData) {
        final prodId = item['product_id'];
        final prodName = (item['product_name'] ?? item['name'] ?? '').toString();
        final qty = _parseDouble(item['quantity'], 1.0);
        final unitPrice = _parseDouble(item['unit_price'] ?? item['sellingPrice']);
        final itemDisc = _parseDouble(item['discount_amount'] ?? item['discount']);
        final itemTax = _parseDouble(item['tax_amount'] ?? item['tax']);
        final itemTotal = _parseDouble(item['total_amount'] ?? item['total']);

        final itemRes = await session.execute(
          Sql.named('''
            INSERT INTO pos_order_items (
              order_id, product_id, product_name, quantity, unit_price, discount_amount, tax_amount, total_amount
            )
            VALUES (
              @orderId, @productId, @productName, @quantity, @unitPrice, @discountAmount, @taxAmount, @totalAmount
            )
            RETURNING id
          '''),
          parameters: {
            'orderId': int.tryParse(orderId.toString()) ?? orderId,
            'productId': int.tryParse(prodId.toString()) ?? prodId.toString(),
            'productName': prodName,
            'quantity': qty,
            'unitPrice': unitPrice,
            'discountAmount': itemDisc,
            'taxAmount': itemTax,
            'totalAmount': itemTotal,
          },
        );

        // Decrease product stock
        await session.execute(
          Sql.named("UPDATE products SET stock_quantity = stock_quantity - @qty, updated_at = CURRENT_TIMESTAMP WHERE id::text = @idStr"),
          parameters: {'qty': qty, 'idStr': prodId.toString()},
        );

        insertedItems.add(OrderItemModel(
          id: int.tryParse(itemRes.first[0].toString()),
          orderId: int.tryParse(orderId.toString()),
          productId: int.tryParse(prodId.toString()) ?? 0,
          productName: prodName,
          quantity: qty,
          unitPrice: unitPrice,
          discountAmount: itemDisc,
          taxAmount: itemTax,
          totalAmount: itemTotal,
        ));
      }

      // 4. Insert payment records
      final insertedPayments = <PaymentModel>[];
      for (final p in paymentsData) {
        final pMethod = (p['payment_method'] ?? paymentMethod).toString();
        final pAmt = _parseDouble(p['amount'], grandTotal);
        final pRef = p['reference_number']?.toString();

        final payNumber = 'PAY-${DateTime.now().millisecondsSinceEpoch % 10000000}';
        final payRes = await session.execute(
          Sql.named('''
            INSERT INTO payments (id, payment_number, order_id, payment_method, method, amount, reference_number, status)
            VALUES (gen_random_uuid(), @payNumber, @orderId, @pMethod, @pMethod, @pAmt, @pRef, 'PAID')
            RETURNING id, created_at
          '''),
          parameters: {
            'payNumber': payNumber,
            'orderId': orderId.toString(),
            'pMethod': pMethod,
            'pAmt': pAmt,
            'pRef': pRef,
          },
        );

        insertedPayments.add(PaymentModel(
          id: int.tryParse(payRes.first[0].toString()),
          orderId: int.tryParse(orderId.toString()),
          paymentMethod: pMethod,
          amount: pAmt,
          referenceNumber: pRef,
          createdAt: DateTime.parse(payRes.first[1].toString()),
        ));
      }

      createdOrder = PosOrderModel(
        id: int.tryParse(orderId.toString()),
        orderNumber: orderNumber,
        customerId: customerId,
        cashierId: cashierId,
        subtotal: subtotal,
        discountAmount: discountAmount,
        taxAmount: taxAmount,
        grandTotal: grandTotal,
        paymentStatus: 'paid',
        orderStatus: 'paid',
        paymentMethod: paymentMethod,
        amountReceived: amountReceived,
        changeAmount: changeAmount,
        items: insertedItems,
        payments: insertedPayments,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    });

    return createdOrder;
  }

  Future<List<PosOrderModel>> getAllOrders({
    String? search,
    String? status,
    String? paymentMethod,
    String? date,
    int limit = 50,
    int offset = 0,
  }) async {
    String sql = '''
      SELECT o.*, 
             COALESCE(u.full_name, e.full_name, 'Cashier') as cashier_name,
             (SELECT COALESCE(p.payment_method, p.method, 'cash') FROM payments p WHERE p.order_id::text = o.id::text OR p.invoice_id::text = o.id::text LIMIT 1) as payment_method
      FROM pos_orders o
      LEFT JOIN users u ON o.cashier_id::text = u.id::text
      LEFT JOIN employees e ON e.user_id::text = u.id::text OR e.id::text = o.cashier_id::text
      WHERE 1=1
    ''';

    final params = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      sql += ' AND LOWER(o.order_number) LIKE LOWER(@search)';
      params['search'] = '%${search.trim()}%';
    }

    if (status != null && status.isNotEmpty && status != 'all') {
      sql += ' AND (o.order_status = @status OR o.payment_status = @status)';
      params['status'] = status;
    }

    if (paymentMethod != null && paymentMethod.isNotEmpty && paymentMethod != 'all') {
      sql += ' AND EXISTS (SELECT 1 FROM payments p WHERE (p.order_id::text = o.id::text OR p.invoice_id::text = o.id::text) AND LOWER(COALESCE(p.payment_method, p.method, '')) = LOWER(@payMethod))';
      params['payMethod'] = paymentMethod;
    }

    if (date != null && date.isNotEmpty) {
      sql += ' AND DATE(o.created_at) = @date::date';
      params['date'] = date;
    }

    sql += ' ORDER BY o.created_at DESC LIMIT $limit OFFSET $offset';

    final result = await db.connection.execute(Sql.named(sql), parameters: params);

    final orders = <PosOrderModel>[];
    for (final row in result) {
      final map = row.toColumnMap();
      final orderId = map['id'];

      // Fetch items for each order
      final itemsRes = await db.connection.execute(
        Sql.named('SELECT * FROM pos_order_items WHERE order_id = @orderId OR order_id::text = @orderIdStr'),
        parameters: {'orderId': orderId, 'orderIdStr': orderId.toString()},
      );
      final items = itemsRes.map((i) => OrderItemModel.fromJson(i.toColumnMap())).toList();

      // Fetch payments for each order
      final paymentsRes = await db.connection.execute(
        Sql.named('SELECT * FROM payments WHERE order_id::text = @orderIdStr OR invoice_id::text = @orderIdStr'),
        parameters: {'orderIdStr': orderId.toString()},
      );
      final payments = paymentsRes.map((p) => PaymentModel.fromJson(p.toColumnMap())).toList();

      map['items'] = items.map((i) => i.toJson()).toList();
      map['payments'] = payments.map((p) => p.toJson()).toList();

      orders.add(PosOrderModel.fromJson(map));
    }

    return orders;
  }

  Future<PosOrderModel?> findById(dynamic id) async {
    final sql = '''
      SELECT o.*, 
             COALESCE(u.full_name, e.full_name, 'Cashier') as cashier_name,
             (SELECT COALESCE(p.payment_method, p.method, 'cash') FROM payments p WHERE p.order_id::text = o.id::text OR p.invoice_id::text = o.id::text LIMIT 1) as payment_method
      FROM pos_orders o
      LEFT JOIN users u ON o.cashier_id::text = u.id::text
      LEFT JOIN employees e ON e.user_id::text = u.id::text OR e.id::text = o.cashier_id::text
      WHERE o.id = @id OR o.id::text = @idStr OR o.order_number = @idStr
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'id': id, 'idStr': id.toString()});
    if (result.isEmpty) return null;

    final map = result.first.toColumnMap();

    final itemsRes = await db.connection.execute(
      Sql.named('SELECT * FROM pos_order_items WHERE order_id = @id OR order_id::text = @idStr'),
      parameters: {'id': id, 'idStr': id.toString()},
    );
    final paymentsRes = await db.connection.execute(
      Sql.named('SELECT * FROM payments WHERE order_id::text = @idStr OR invoice_id::text = @idStr'),
      parameters: {'idStr': id.toString()},
    );

    map['items'] = itemsRes.map((i) => i.toColumnMap()).toList();
    map['payments'] = paymentsRes.map((p) => p.toColumnMap()).toList();

    return PosOrderModel.fromJson(map);
  }

  Future<void> cancelOrder(dynamic orderId) async {
    await db.connection.runTx((session) async {
      final items = await session.execute(
        Sql.named('SELECT product_id, quantity FROM pos_order_items WHERE order_id = @id OR order_id::text = @idStr'),
        parameters: {'id': orderId, 'idStr': orderId.toString()},
      );

      for (final row in items) {
        final prodId = row[0];
        final qty = _parseDouble(row[1]);
        await session.execute(
          Sql.named('UPDATE products SET stock_quantity = stock_quantity + @qty WHERE id = @prodId OR id::text = @prodIdStr'),
          parameters: {'qty': qty, 'prodId': prodId, 'prodIdStr': prodId.toString()},
        );
      }

      await session.execute(
        Sql.named("UPDATE pos_orders SET order_status = 'cancelled', payment_status = 'cancelled', updated_at = CURRENT_TIMESTAMP WHERE id = @id OR id::text = @idStr"),
        parameters: {'id': orderId, 'idStr': orderId.toString()},
      );
    });
  }
}
