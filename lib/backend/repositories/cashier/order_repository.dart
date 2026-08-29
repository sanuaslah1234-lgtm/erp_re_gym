import 'package:erp_software/core/models/cashier/order_item_model.dart';
import 'package:erp_software/core/models/cashier/payment_model.dart';
import 'package:erp_software/core/models/cashier/pos_order_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:postgres/postgres.dart';

class OrderRepository {
  final PostgresService db;

  OrderRepository(this.db);

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
        final prodId = item['product_id'] as int;
        final requestedQty = (item['quantity'] as num).toDouble();

        final prodRes = await session.execute(
          Sql.named("SELECT name, stock_quantity FROM products WHERE id = @id FOR UPDATE"),
          parameters: {'id': prodId},
        );

        if (prodRes.isEmpty) {
          throw ApiException('Product ID $prodId not found', statusCode: 400);
        }

        final currentStock = (prodRes.first[1] as num).toDouble();
        final prodName = prodRes.first[0] as String;

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

      final orderId = orderRes.first[0] as int;
      final createdAt = DateTime.parse(orderRes.first[1].toString());
      final updatedAt = DateTime.parse(orderRes.first[2].toString());

      // 3. Insert order items & decrease product stock
      final insertedItems = <OrderItemModel>[];
      for (final item in itemsData) {
        final prodId = item['product_id'] as int;
        final prodName = item['product_name'] as String;
        final qty = (item['quantity'] as num).toDouble();
        final unitPrice = (item['unit_price'] as num).toDouble();
        final itemDisc = (item['discount_amount'] as num).toDouble();
        final itemTax = (item['tax_amount'] as num).toDouble();
        final itemTotal = (item['total_amount'] as num).toDouble();

        final itemRes = await session.execute(
          Sql.named('''
            INSERT INTO pos_order_items (
              order_id, product_id, product_name, quantity, unit_price, discount_amount, tax_amount, total_amount
            )
            VALUES (
              @orderId, @prodId, @prodName, @qty, @unitPrice, @itemDisc, @itemTax, @itemTotal
            )
            RETURNING id
          '''),
          parameters: {
            'orderId': orderId,
            'prodId': prodId,
            'prodName': prodName,
            'qty': qty,
            'unitPrice': unitPrice,
            'itemDisc': itemDisc,
            'itemTax': itemTax,
            'itemTotal': itemTotal,
          },
        );

        // Decrease stock
        await session.execute(
          Sql.named("UPDATE products SET stock_quantity = stock_quantity - @qty, updated_at = CURRENT_TIMESTAMP WHERE id = @prodId"),
          parameters: {'qty': qty, 'prodId': prodId},
        );

        insertedItems.add(OrderItemModel(
          id: itemRes.first[0] as int,
          orderId: orderId,
          productId: prodId,
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
        final pMethod = p['payment_method'] as String;
        final pAmt = (p['amount'] as num).toDouble();
        final pRef = p['reference_number'] as String?;

        final payRes = await session.execute(
          Sql.named('''
            INSERT INTO payments (order_id, payment_method, amount, reference_number)
            VALUES (@orderId, @pMethod, @pAmt, @pRef)
            RETURNING id, created_at
          '''),
          parameters: {
            'orderId': orderId,
            'pMethod': pMethod,
            'pAmt': pAmt,
            'pRef': pRef,
          },
        );

        insertedPayments.add(PaymentModel(
          id: payRes.first[0] as int,
          orderId: orderId,
          paymentMethod: pMethod,
          amount: pAmt,
          referenceNumber: pRef,
          createdAt: DateTime.parse(payRes.first[1].toString()),
        ));
      }

      createdOrder = PosOrderModel(
        id: orderId,
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
      SELECT o.*, e.full_name as cashier_name,
             (SELECT payment_method FROM payments WHERE order_id = o.id LIMIT 1) as payment_method
      FROM pos_orders o
      LEFT JOIN users u ON o.cashier_id = u.id
      LEFT JOIN employees e ON e.user_id = u.id
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
      sql += ' AND EXISTS (SELECT 1 FROM payments p WHERE p.order_id = o.id AND LOWER(p.payment_method) = LOWER(@payMethod))';
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
      final orderId = map['id'] as int;

      // Fetch items for each order
      final itemsRes = await db.connection.execute(
        Sql.named('SELECT * FROM pos_order_items WHERE order_id = @orderId'),
        parameters: {'orderId': orderId},
      );
      final items = itemsRes.map((i) => OrderItemModel.fromJson(i.toColumnMap())).toList();

      // Fetch payments for each order
      final paymentsRes = await db.connection.execute(
        Sql.named('SELECT * FROM payments WHERE order_id = @orderId'),
        parameters: {'orderId': orderId},
      );
      final payments = paymentsRes.map((p) => PaymentModel.fromJson(p.toColumnMap())).toList();

      map['items'] = items.map((i) => i.toJson()).toList();
      map['payments'] = payments.map((p) => p.toJson()).toList();

      orders.add(PosOrderModel.fromJson(map));
    }

    return orders;
  }

  Future<PosOrderModel?> findById(int id) async {
    final sql = '''
      SELECT o.*, e.full_name as cashier_name,
             (SELECT payment_method FROM payments WHERE order_id = o.id LIMIT 1) as payment_method
      FROM pos_orders o
      LEFT JOIN users u ON o.cashier_id = u.id
      LEFT JOIN employees e ON e.user_id = u.id
      WHERE o.id = @id
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'id': id});
    if (result.isEmpty) return null;

    final map = result.first.toColumnMap();

    final itemsRes = await db.connection.execute(
      Sql.named('SELECT * FROM pos_order_items WHERE order_id = @id'),
      parameters: {'id': id},
    );
    final paymentsRes = await db.connection.execute(
      Sql.named('SELECT * FROM payments WHERE order_id = @id'),
      parameters: {'id': id},
    );

    map['items'] = itemsRes.map((i) => i.toColumnMap()).toList();
    map['payments'] = paymentsRes.map((p) => p.toColumnMap()).toList();

    return PosOrderModel.fromJson(map);
  }

  Future<void> cancelOrder(int orderId) async {
    await db.connection.runTx((session) async {
      final items = await session.execute(
        Sql.named('SELECT product_id, quantity FROM pos_order_items WHERE order_id = @id'),
        parameters: {'id': orderId},
      );

      for (final row in items) {
        final prodId = row[0] as int;
        final qty = (row[1] as num).toDouble();
        await session.execute(
          Sql.named('UPDATE products SET stock_quantity = stock_quantity + @qty WHERE id = @prodId'),
          parameters: {'qty': qty, 'prodId': prodId},
        );
      }

      await session.execute(
        Sql.named("UPDATE pos_orders SET order_status = 'cancelled', payment_status = 'cancelled', updated_at = CURRENT_TIMESTAMP WHERE id = @id"),
        parameters: {'id': orderId},
      );
    });
  }
}


