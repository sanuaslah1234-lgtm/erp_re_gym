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

    final count = int.tryParse(result.first[0]?.toString() ?? '0') ?? 0;
    return "$prefix${(count + 1).toString().padLeft(4, '0')}";
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
        final orderItemId = int.tryParse(item['order_item_id'].toString()) ?? item['order_item_id'];
        final requestedRefundQty = double.tryParse(item['quantity'].toString()) ?? 1.0;

        final itemRes = await session.execute(
          Sql.named('''
            SELECT product_id, product_name, quantity, total_amount
            FROM pos_order_items
            WHERE (id = @orderItemId OR id::text = @orderItemIdStr) AND (order_id = @orderId OR order_id::text = @orderIdStr)
          '''),
          parameters: {'orderItemId': orderItemId, 'orderItemIdStr': orderItemId.toString(), 'orderId': orderId, 'orderIdStr': orderId.toString()},
        );

        if (itemRes.isEmpty) {
          throw ApiException('Order item #$orderItemId not found in Order #$orderNumber', statusCode: 400);
        }

        final productId = int.tryParse(itemRes.first[0]?.toString() ?? '0') ?? 0;
        final productName = itemRes.first[1].toString();
        final purchasedQty = double.tryParse(itemRes.first[2]?.toString() ?? '0') ?? 0.0;
        final totalItemAmount = double.tryParse(itemRes.first[3]?.toString() ?? '0') ?? 0.0;
        final unitRefundPrice = purchasedQty > 0 ? totalItemAmount / purchasedQty : 0.0;

        // Sum previously refunded quantity for this order item
        final prevRefundRes = await session.execute(
          Sql.named('SELECT COALESCE(SUM(quantity), 0) FROM refund_items WHERE order_item_id = @orderItemId OR order_item_id::text = @orderItemIdStr'),
          parameters: {'orderItemId': orderItemId, 'orderItemIdStr': orderItemId.toString()},
        );
        final alreadyRefundedQty = double.tryParse(prevRefundRes.first[0]?.toString() ?? '0') ?? 0.0;
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

      final refundId = int.tryParse(refundRes.first[0].toString()) ?? refundRes.first[0];
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
          Sql.named('UPDATE products SET stock_quantity = stock_quantity + @qty, updated_at = CURRENT_TIMESTAMP WHERE id = @prodId OR id::text = @prodIdStr'),
          parameters: {'qty': vi['quantity'], 'prodId': vi['product_id'], 'prodIdStr': vi['product_id'].toString()},
        );

        insertedRefundItems.add(RefundItemModel(
          id: int.tryParse(rItemRes.first[0].toString()),
          refundId: int.tryParse(refundId.toString()),
          orderItemId: int.tryParse(vi['order_item_id'].toString()) ?? 0,
          productId: int.tryParse(vi['product_id'].toString()) ?? 0,
          productName: vi['product_name'].toString(),
          quantity: double.tryParse(vi['quantity']?.toString() ?? '0') ?? 0.0,
          refundAmount: double.tryParse(vi['refund_amount']?.toString() ?? '0') ?? 0.0,
        ));
      }

      // 5. Check if all items in order are fully refunded or partially refunded
      final totalPurchasedQtyRes = await session.execute(
        Sql.named('SELECT COALESCE(SUM(quantity), 0) FROM pos_order_items WHERE order_id = @orderId OR order_id::text = @orderIdStr'),
        parameters: {'orderId': orderId, 'orderIdStr': orderId.toString()},
      );
      final totalRefundedQtyRes = await session.execute(
        Sql.named('''
          SELECT COALESCE(SUM(ri.quantity), 0)
          FROM refund_items ri
          JOIN refunds r ON ri.refund_id = r.id
          WHERE r.order_id = @orderId OR r.order_id::text = @orderIdStr
        '''),
        parameters: {'orderId': orderId, 'orderIdStr': orderId.toString()},
      );

      final totalPurchased = double.tryParse(totalPurchasedQtyRes.first[0]?.toString() ?? '0') ?? 0.0;
      final totalRefunded = double.tryParse(totalRefundedQtyRes.first[0]?.toString() ?? '0') ?? 0.0;

      final newStatus = totalRefunded >= totalPurchased ? 'refunded' : 'partially_refunded';
      await session.execute(
        Sql.named("UPDATE pos_orders SET payment_status = @status, order_status = @status, updated_at = CURRENT_TIMESTAMP WHERE id = @orderId OR id::text = @orderIdStr"),
        parameters: {'status': newStatus, 'orderId': orderId, 'orderIdStr': orderId.toString()},
      );

      createdRefund = RefundModel(
        id: int.tryParse(refundId.toString()),
        refundNumber: refundNumber,
        orderId: int.tryParse(orderId.toString()) ?? 0,
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
      SELECT r.*, o.order_number, 
             COALESCE(u.full_name, e.full_name, 'Staff') as processor_name
      FROM refunds r
      LEFT JOIN pos_orders o ON r.order_id::text = o.id::text OR r.original_order_id::text = o.id::text
      LEFT JOIN users u ON r.processed_by::text = u.id::text
      LEFT JOIN employees e ON e.user_id::text = u.id::text OR e.id::text = r.processed_by::text
      ORDER BY r.created_at DESC
    ''';

    final result = await db.connection.execute(sql);
    final refunds = <RefundModel>[];

    for (final row in result) {
      final map = row.toColumnMap();
      final refundId = map['id'];

      final itemsRes = await db.connection.execute(
        Sql.named('''
          SELECT ri.*, p.name as product_name
          FROM refund_items ri
          JOIN products p ON ri.product_id::text = p.id::text
          WHERE ri.refund_id = @refundId OR ri.refund_id::text = @refundIdStr
        '''),
        parameters: {'refundId': refundId, 'refundIdStr': refundId.toString()},
      );

      map['items'] = itemsRes.map((i) => i.toColumnMap()).toList();
      refunds.add(RefundModel.fromJson(map));
    }

    return refunds;
  }

  Future<RefundModel?> findById(int id) async {
    final sql = '''
      SELECT r.*, o.order_number, 
             COALESCE(u.full_name, e.full_name, 'Staff') as processor_name
      FROM refunds r
      LEFT JOIN pos_orders o ON r.order_id::text = o.id::text OR r.original_order_id::text = o.id::text
      LEFT JOIN users u ON r.processed_by::text = u.id::text
      LEFT JOIN employees e ON e.user_id::text = u.id::text OR e.id::text = r.processed_by::text
      WHERE r.id = @id OR r.id::text = @idStr
      LIMIT 1
    ''';

    final result = await db.connection.execute(Sql.named(sql), parameters: {'id': id, 'idStr': id.toString()});
    if (result.isEmpty) return null;

    final map = result.first.toColumnMap();
    final itemsRes = await db.connection.execute(
      Sql.named('''
        SELECT ri.*, p.name as product_name
        FROM refund_items ri
        JOIN products p ON ri.product_id::text = p.id::text
        WHERE ri.refund_id = @id OR ri.refund_id::text = @idStr
      '''),
      parameters: {'id': id, 'idStr': id.toString()},
    );

    map['items'] = itemsRes.map((i) => i.toColumnMap()).toList();
    return RefundModel.fromJson(map);
  }
}


