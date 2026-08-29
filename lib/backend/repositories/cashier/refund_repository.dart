import 'package:erp_software/core/models/cashier/refund_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:postgres/postgres.dart';

class RefundRepository {
  final PostgresService db;

  RefundRepository(this.db);

  Future<String> generateRefundNumber() async {
    final now = DateTime.now();
    final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final prefix = "REF-$dateStr-";

    final result = await db.connection.execute(
      Sql.named("SELECT COUNT(*) FROM refunds WHERE refund_number LIKE @prefix"),
      parameters: {'prefix': '$prefix%'},
    );

    final count = (result.first[0] as num).toInt() + 1;
    return "$prefix${count.toString().padLeft(4, '0')}";
  }

  /// Processes a full or partial refund within a single PostgreSQL transaction (`runTx`)
  Future<RefundModel> createRefundInTx({
    required int orderId,
    required int processedBy,
    required String refundMethod,
    String? reason,
    required List<Map<String, dynamic>> itemsToRefund,
  }) async {
    final refundNumber = await generateRefundNumber();
    late RefundModel createdRefund;

    await db.connection.runTx((session) async {
      // 1. Verify order exists
      final orderRes = await session.execute(
        Sql.named('SELECT order_number, grand_total, order_status FROM pos_orders WHERE id = @id FOR UPDATE'),
        parameters: {'id': orderId},
      );

      if (orderRes.isEmpty) {
        throw ApiException('Order #$orderId not found', statusCode: 404);
      }

      final orderNumber = orderRes.first[0] as String;
      final currentOrderStatus = orderRes.first[2] as String;

      if (currentOrderStatus == 'cancelled') {
        throw ApiException('Cannot refund a cancelled order', statusCode: 400);
      }

      // 2. Validate refund quantities against original order items minus already refunded quantities
      double totalRefundAmount = 0.0;
      final validatedItems = <Map<String, dynamic>>[];

      for (final item in itemsToRefund) {
        final orderItemId = item['order_item_id'] as int;
        final requestedRefundQty = (item['quantity'] as num).toDouble();

        final itemRes = await session.execute(
          Sql.named('''
            SELECT product_id, product_name, quantity, total_amount
            FROM pos_order_items
            WHERE id = @orderItemId AND order_id = @orderId
          '''),
          parameters: {'orderItemId': orderItemId, 'orderId': orderId},
        );

        if (itemRes.isEmpty) {
          throw ApiException('Order item #$orderItemId not found in Order #$orderNumber', statusCode: 400);
        }

        final productId = itemRes.first[0] as int;
        final productName = itemRes.first[1] as String;
        final purchasedQty = (itemRes.first[2] as num).toDouble();
        final totalItemAmount = (itemRes.first[3] as num).toDouble();
        final unitRefundPrice = purchasedQty > 0 ? totalItemAmount / purchasedQty : 0.0;

        // Sum previously refunded quantity for this order item
        final prevRefundRes = await session.execute(
          Sql.named('SELECT COALESCE(SUM(quantity), 0) FROM refund_items WHERE order_item_id = @orderItemId'),
          parameters: {'orderItemId': orderItemId},
        );
        final alreadyRefundedQty = (prevRefundRes.first[0] as num).toDouble();
        final maxRefundableQty = purchasedQty - alreadyRefundedQty;

        if (requestedRefundQty <= 0) {
          throw ApiException('Refund quantity must be greater than zero', statusCode: 400);
        }

        if (requestedRefundQty > maxRefundableQty) {
          throw ApiException(
            'Cannot refund $requestedRefundQty of "$productName". Maximum refundable quantity remaining: $maxRefundableQty',
            statusCode: 400,
          );
        }

        final itemRefundAmount = requestedRefundQty * unitRefundPrice;
        totalRefundAmount += itemRefundAmount;

        validatedItems.add({
          'order_item_id': orderItemId,
          'product_id': productId,
          'product_name': productName,
          'quantity': requestedRefundQty,
          'refund_amount': itemRefundAmount,
        });
      }

      // 3. Insert refund header
      final refundRes = await session.execute(
        Sql.named('''
          INSERT INTO refunds (refund_number, order_id, refund_amount, refund_method, reason, processed_by)
          VALUES (@refundNumber, @orderId, @refundAmount, @refundMethod, @reason, @processedBy)
          RETURNING id, created_at
        '''),
        parameters: {
          'refundNumber': refundNumber,
          'orderId': orderId,
          'refundAmount': totalRefundAmount,
          'refundMethod': refundMethod,
          'reason': reason ?? 'Customer Return',
          'processedBy': processedBy,
        },
      );

      final refundId = refundRes.first[0] as int;
      final createdAt = DateTime.parse(refundRes.first[1].toString());

      // 4. Insert refund items & restore product stock
      final insertedRefundItems = <RefundItemModel>[];
      for (final vi in validatedItems) {
        final rItemRes = await session.execute(
          Sql.named('''
            INSERT INTO refund_items (refund_id, order_item_id, product_id, quantity, refund_amount)
            VALUES (@refundId, @orderItemId, @productId, @qty, @refundAmt)
            RETURNING id
          '''),
          parameters: {
            'refundId': refundId,
            'orderItemId': vi['order_item_id'],
            'productId': vi['product_id'],
            'qty': vi['quantity'],
            'refundAmt': vi['refund_amount'],
          },
        );

        // Increase product stock (restoration)
        await session.execute(
          Sql.named('UPDATE products SET stock_quantity = stock_quantity + @qty, updated_at = CURRENT_TIMESTAMP WHERE id = @prodId'),
          parameters: {'qty': vi['quantity'], 'prodId': vi['product_id']},
        );

        insertedRefundItems.add(RefundItemModel(
          id: rItemRes.first[0] as int,
          refundId: refundId,
          orderItemId: vi['order_item_id'] as int,
          productId: vi['product_id'] as int,
          productName: vi['product_name'] as String,
          quantity: vi['quantity'] as double,
          refundAmount: vi['refund_amount'] as double,
        ));
      }

      // 5. Check if all items in order are fully refunded or partially refunded
      final totalPurchasedQtyRes = await session.execute(
        Sql.named('SELECT COALESCE(SUM(quantity), 0) FROM pos_order_items WHERE order_id = @orderId'),
        parameters: {'orderId': orderId},
      );
      final totalRefundedQtyRes = await session.execute(
        Sql.named('''
          SELECT COALESCE(SUM(ri.quantity), 0)
          FROM refund_items ri
          JOIN refunds r ON ri.refund_id = r.id
          WHERE r.order_id = @orderId
        '''),
        parameters: {'orderId': orderId},
      );

      final totalPurchased = (totalPurchasedQtyRes.first[0] as num).toDouble();
      final totalRefunded = (totalRefundedQtyRes.first[0] as num).toDouble();

      final newStatus = totalRefunded >= totalPurchased ? 'refunded' : 'partially_refunded';
      await session.execute(
        Sql.named("UPDATE pos_orders SET payment_status = @status, order_status = @status, updated_at = CURRENT_TIMESTAMP WHERE id = @orderId"),
        parameters: {'status': newStatus, 'orderId': orderId},
      );

      createdRefund = RefundModel(
        id: refundId,
        refundNumber: refundNumber,
        orderId: orderId,
        orderNumber: orderNumber,
        refundAmount: totalRefundAmount,
        refundMethod: refundMethod,
        reason: reason,
        processedBy: processedBy,
        items: insertedRefundItems,
        createdAt: createdAt,
      );
    });

    return createdRefund;
  }

  Future<List<RefundModel>> getAllRefunds() async {
    final sql = '''
      SELECT r.*, o.order_number, e.full_name as processor_name
      FROM refunds r
      JOIN pos_orders o ON r.order_id = o.id
      LEFT JOIN users u ON r.processed_by = u.id
      LEFT JOIN employees e ON e.user_id = u.id
      ORDER BY r.created_at DESC
    ''';

    final result = await db.connection.execute(sql);
    final refunds = <RefundModel>[];

    for (final row in result) {
      final map = row.toColumnMap();
      final refundId = map['id'] as int;

      final itemsRes = await db.connection.execute(
        Sql.named('''
          SELECT ri.*, p.name as product_name
          FROM refund_items ri
          JOIN products p ON ri.product_id = p.id
          WHERE ri.refund_id = @refundId
        '''),
        parameters: {'refundId': refundId},
      );

      map['items'] = itemsRes.map((i) => i.toColumnMap()).toList();
      refunds.add(RefundModel.fromJson(map));
    }

    return refunds;
  }

  Future<RefundModel?> findById(int id) async {
    final sql = '''
      SELECT r.*, o.order_number, e.full_name as processor_name
      FROM refunds r
      JOIN pos_orders o ON r.order_id = o.id
      LEFT JOIN users u ON r.processed_by = u.id
      LEFT JOIN employees e ON e.user_id = u.id
      WHERE r.id = @id
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'id': id});
    if (result.isEmpty) return null;

    final map = result.first.toColumnMap();
    final itemsRes = await db.connection.execute(
      Sql.named('''
        SELECT ri.*, p.name as product_name
        FROM refund_items ri
        JOIN products p ON ri.product_id = p.id
        WHERE ri.refund_id = @id
      '''),
      parameters: {'id': id},
    );

    map['items'] = itemsRes.map((i) => i.toColumnMap()).toList();
    return RefundModel.fromJson(map);
  }
}


