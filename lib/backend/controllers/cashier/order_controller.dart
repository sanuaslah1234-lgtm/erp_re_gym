import 'dart:convert';
import 'package:erp_software/backend/services/cashier/order_service.dart';
import 'package:erp_software/backend/services/jwt_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/backend/utils/response_utils.dart';
import 'package:shelf/shelf.dart';

class OrderController {
  final OrderService orderService;

  OrderController(this.orderService);

  Future<Response> createOrder(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return ResponseUtils.error(message: 'Request body cannot be empty', statusCode: 400);
      }

      final body = jsonDecode(bodyStr) as Map<String, dynamic>;
      final user = request.context['user'] as JwtPayload?;
      final cashierId = user?.userId ?? body['cashierId'] ?? 1;

      final itemsData = (body['items'] as List? ?? []).cast<Map<String, dynamic>>();
      final paymentsData = (body['payments'] as List? ?? []).cast<Map<String, dynamic>>();

      double toDbl(dynamic v) {
        if (v == null) return 0.0;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      }

      final order = await orderService.createOrder(
        cashierId: int.tryParse(cashierId.toString()) ?? 1,
        customerId: body['customerId'] != null ? int.tryParse(body['customerId'].toString()) : null,
        subtotal: toDbl(body['subtotal']),
        discountAmount: toDbl(body['discountAmount']),
        taxAmount: toDbl(body['taxAmount']),
        grandTotal: toDbl(body['grandTotal']),
        amountReceived: toDbl(body['amountReceived']),
        changeAmount: toDbl(body['changeAmount']),
        paymentMethod: body['paymentMethod']?.toString() ?? 'Cash',
        itemsData: itemsData,
        paymentsData: paymentsData.isNotEmpty ? paymentsData : [
          {
            'payment_method': body['paymentMethod']?.toString() ?? 'Cash',
            'amount': toDbl(body['grandTotal']),
            'reference_number': body['referenceNumber']?.toString(),
          }
        ],
      );

      return ResponseUtils.success(
        message: 'Order ${order.orderNumber} created successfully!',
        data: order.toJson(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to create order: $e', statusCode: 500, error: e);
    }
  }

  Future<Response> getOrders(Request request) async {
    try {
      final params = request.url.queryParameters;
      final search = params['search'];
      final status = params['status'];
      final paymentMethod = params['paymentMethod'];
      final date = params['date'];
      final limit = int.tryParse(params['limit'] ?? '50') ?? 50;
      final offset = int.tryParse(params['offset'] ?? '0') ?? 0;

      final orders = await orderService.getOrders(
        search: search,
        status: status,
        paymentMethod: paymentMethod,
        date: date,
        limit: limit,
        offset: offset,
      );

      return ResponseUtils.success(
        message: 'Orders fetched successfully',
        data: orders.map((o) => o.toJson()).toList(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to fetch orders', statusCode: 500, error: e);
    }
  }

  Future<Response> getOrderById(Request request, String idStr) async {
    try {
      final id = int.tryParse(idStr);
      if (id == null) {
        return ResponseUtils.error(message: 'Invalid order ID', statusCode: 400);
      }

      final order = await orderService.getOrderById(id);
      return ResponseUtils.success(
        message: 'Order details fetched',
        data: order.toJson(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to fetch order', statusCode: 500, error: e);
    }
  }

  Future<Response> cancelOrder(Request request, String idStr) async {
    try {
      final id = int.tryParse(idStr);
      if (id == null) {
        return ResponseUtils.error(message: 'Invalid order ID', statusCode: 400);
      }

      await orderService.cancelOrder(id);
      return ResponseUtils.success(message: 'Order cancelled successfully and stock restored.');
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to cancel order', statusCode: 500, error: e);
    }
  }
}

