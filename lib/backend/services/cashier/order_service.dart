import 'package:erp_software/core/models/cashier/pos_order_model.dart';
import 'package:erp_software/backend/repositories/cashier/cashier_settings_repository.dart';
import 'package:erp_software/backend/repositories/cashier/order_repository.dart';
import 'package:erp_software/core/errors/app_exception.dart';

class OrderService {
  final OrderRepository orderRepository;
  final CashierSettingsRepository settingsRepository;

  OrderService({
    required this.orderRepository,
    required this.settingsRepository,
  });

  Future<PosOrderModel> createOrder({
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
  }) async {
    // 1. Validation
    if (itemsData.isEmpty) {
      throw ApiException('Cannot create order with an empty cart', statusCode: 400);
    }

    final settings = await settingsRepository.getSettings();

    if (settings.requireCustomer && customerId == null) {
      throw ApiException('Customer selection is required by cashier settings', statusCode: 400);
    }

    if (paymentMethod == 'Cash' && amountReceived < grandTotal) {
      throw ApiException('Amount received (\$$amountReceived) cannot be less than grand total (\$$grandTotal)', statusCode: 400);
    }

    return await orderRepository.createOrderInTx(
      cashierId: cashierId,
      customerId: customerId,
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      grandTotal: grandTotal,
      amountReceived: amountReceived,
      changeAmount: changeAmount,
      paymentMethod: paymentMethod,
      itemsData: itemsData,
      paymentsData: paymentsData,
      allowNegativeStock: settings.allowNegativeStock,
    );
  }

  Future<List<PosOrderModel>> getOrders({
    String? search,
    String? status,
    String? paymentMethod,
    String? date,
    int limit = 50,
    int offset = 0,
  }) async {
    return await orderRepository.getAllOrders(
      search: search,
      status: status,
      paymentMethod: paymentMethod,
      date: date,
      limit: limit,
      offset: offset,
    );
  }

  Future<PosOrderModel> getOrderById(int id) async {
    final order = await orderRepository.findById(id);
    if (order == null) {
      throw ApiException('Order #$id not found', statusCode: 404);
    }
    return order;
  }

  Future<void> cancelOrder(int id) async {
    await orderRepository.cancelOrder(id);
  }
}

