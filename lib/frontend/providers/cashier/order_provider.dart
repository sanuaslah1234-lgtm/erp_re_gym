import 'package:flutter/foundation.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:erp_software/frontend/services/cashier/order_api_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderApiService _orderApiService = OrderApiService();

  List<PosOrder> _orders = [];
  PosOrder? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedPaymentMethod = 'all';
  String? _selectedDate;

  List<PosOrder> get orders => _orders;
  PosOrder? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String? get selectedDate => _selectedDate;

  Future<void> fetchOrders(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderApiService.getOrders(
        token,
        search: _searchQuery,
        status: _selectedStatus,
        paymentMethod: _selectedPaymentMethod,
        date: _selectedDate,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterSearch(String search, String? token) {
    _searchQuery = search;
    fetchOrders(token);
  }

  void setFilterStatus(String status, String? token) {
    _selectedStatus = status;
    fetchOrders(token);
  }

  void setFilterPaymentMethod(String method, String? token) {
    _selectedPaymentMethod = method;
    fetchOrders(token);
  }

  void setFilterDate(String? date, String? token) {
    _selectedDate = date;
    fetchOrders(token);
  }

  Future<void> fetchOrderDetails(String? token, int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderApiService.getOrderById(token, orderId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String? token, int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _orderApiService.cancelOrder(token, orderId);
      if (success) {
        await fetchOrders(token);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
