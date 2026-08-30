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
        final prodId = int.tryParse(item['product_id'].toString()) ?? item['product_id'];
        final requestedQty = (item['quantity'] as num).toDouble();

        final prodRes = await session.execute(
          Sql.named("SELECT name, stock_quantity FROM products WHERE id = @id OR id::text = @idStr FOR UPDATE"),
          parameters: {'id': prodId, 'idStr': prodId.toString()},
        );

        if (prodRes.isEmpty) {
          throw ApiException('Product ID $prodId not found', statusCode: 400);
        }

        final currentStock = (prodRes.first[1] as num).toDouble();
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

      final orderId = int.tryParse(orderRes.first[0].toString()) ?? orderRes.first[0];
      final createdAt = DateTime.parse(orderRes.first[1].toString());
      final updatedAt = DateTime.parse(orderRes.first[2].toString());

      // 3. Insert order items & decrease product stock
      final insertedItems = <OrderItemModel>[];
      for (final item in itemsData) {
        final prodId = int.tryParse(item['product_id'].toString()) ?? item['product_id'];
        final prodName = item['product_name'].toString();
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
              @orderId, @productId, @productName, @quantity, @unitPrice, @discountAmount, @taxAmount, @totalAmount
            )
            RETURNING id
          '''),
          parameters: {
            'orderId': orderId,
            'productId': prodId,
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
          Sql.named("UPDATE products SET stock_quantity = stock_quantity - @qty, updated_at = CURRENT_TIMESTAMP WHERE id = @prodId OR id::text = @idStr"),
          parameters: {'qty': qty, 'prodId': prodId, 'idStr': prodId.toString()},
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
        final pMethod = p['payment_method'].toString();
        final pAmt = (p['amount'] as num).toDouble();
        final pRef = p['reference_number']?.toString();

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
      final orderId = map['id'];

      // Fetch items for each order
      final itemsRes = await db.connection.execute(
        Sql.named('SELECT * FROM pos_order_items WHERE order_id = @orderId OR order_id::text = @orderIdStr'),
        parameters: {'orderId': orderId, 'orderIdStr': orderId.toString()},
      );
      final items = itemsRes.map((i) => OrderItemModel.fromJson(i.toColumnMap())).toList();

      // Fetch payments for each order
      final paymentsRes = await db.connection.execute(
        Sql.named('SELECT * FROM payments WHERE order_id = @orderId OR order_id::text = @orderIdStr'),
        parameters: {'orderId': orderId, 'orderIdStr': orderId.toString()},
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
      SELECT o.*, e.full_name as cashier_name,
             (SELECT payment_method FROM payments WHERE order_id = o.id LIMIT 1) as payment_method
      FROM pos_orders o
      LEFT JOIN users u ON o.cashier_id = u.id
      LEFT JOIN employees e ON e.user_id = u.id
      WHERE o.id = @id OR o.id::text = @idStr
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
      Sql.named('SELECT * FROM payments WHERE order_id = @id OR order_id::text = @idStr'),
      parameters: {'id': id, 'idStr': id.toString()},
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
        final qty = (row[1] as num).toDouble();
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


