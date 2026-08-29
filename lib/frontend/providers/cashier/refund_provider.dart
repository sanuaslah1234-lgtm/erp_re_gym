import 'package:flutter/foundation.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:erp_software/core/models/cashier/refund.dart';
import 'package:erp_software/frontend/services/cashier/order_api_service.dart';
import 'package:erp_software/frontend/services/cashier/refund_api_service.dart';

class RefundProvider extends ChangeNotifier {
  final RefundApiService _refundApiService = RefundApiService();
  final OrderApiService _orderApiService = OrderApiService();

  List<Refund> _refunds = [];
  PosOrder? _targetOrderForRefund;
  final Map<int, double> _refundQuantities = {}; // order_item_id -> qty to refund
  String _refundMethod = 'Cash';
  String _refundReason = 'Customer Return';

  bool _isLoading = false;
  String? _errorMessage;

  List<Refund> get refunds => _refunds;
  PosOrder? get targetOrderForRefund => _targetOrderForRefund;
  Map<int, double> get refundQuantities => _refundQuantities;
  String get refundMethod => _refundMethod;
  String get refundReason => _refundReason;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get calculatedRefundTotal {
    if (_targetOrderForRefund == null) return 0.0;
    double total = 0.0;
    for (final item in _targetOrderForRefund!.items) {
      final qty = _refundQuantities[item.id] ?? 0.0;
      if (qty > 0) {
        final unitPrice = item.quantity > 0 ? item.totalAmount / item.quantity : 0.0;
        total += qty * unitPrice;
      }
    }
    return total;
  }

  Future<void> fetchRefunds(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _refunds = await _refundApiService.getRefunds(token);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> searchOrderForRefund(String? token, String orderQuery) async {
    _isLoading = true;
    _errorMessage = null;
    _targetOrderForRefund = null;
    _refundQuantities.clear();
    notifyListeners();

    try {
      final orders = await _orderApiService.getOrders(token, search: orderQuery);
      if (orders.isNotEmpty) {
        _targetOrderForRefund = orders.first;
        // Initialize refund quantities to 0
        for (final item in _targetOrderForRefund!.items) {
          _refundQuantities[item.id] = 0.0;
        }
        return true;
      } else {
        _errorMessage = 'Order "$orderQuery" not found';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRefundQuantity(int orderItemId, double qty, double maxQty) {
    if (qty < 0) qty = 0;
    if (qty > maxQty) qty = maxQty;
    _refundQuantities[orderItemId] = qty;
    notifyListeners();
  }

  void setRefundMethod(String method) {
    _refundMethod = method;
    notifyListeners();
  }

  void setRefundReason(String reason) {
    _refundReason = reason;
    notifyListeners();
  }

  Future<Refund?> processRefund(String? token) async {
    if (_targetOrderForRefund == null) {
      _errorMessage = 'No order selected for refund';
      notifyListeners();
      return null;
    }

    final itemsToRefund = <Map<String, dynamic>>[];
    _refundQuantities.forEach((orderItemId, qty) {
      if (qty > 0) {
        itemsToRefund.add({
          'order_item_id': orderItemId,
          'quantity': qty,
        });
      }
    });

    if (itemsToRefund.isEmpty) {
      _errorMessage = 'Please select at least one item and quantity to refund';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final refundData = {
        'orderId': _targetOrderForRefund!.id,
        'refundMethod': _refundMethod,
        'reason': _refundReason,
        'items': itemsToRefund,
      };

      final refund = await _refundApiService.createRefund(token, refundData);
      _targetOrderForRefund = null;
      _refundQuantities.clear();
      await fetchRefunds(token);
      return refund;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
