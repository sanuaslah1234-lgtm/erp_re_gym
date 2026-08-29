import 'package:flutter/foundation.dart';
import 'package:erp_software/core/models/cashier/cart_item.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:erp_software/core/models/cashier/product.dart';
import 'package:erp_software/frontend/services/cashier/pos_api_service.dart';
import 'package:erp_software/frontend/services/cashier/order_api_service.dart';

class HeldOrder {
  final String id;
  final String label;
  final List<CartItem> items;
  final String? customerName;
  final DateTime heldAt;

  HeldOrder({
    required this.id,
    required this.label,
    required this.items,
    this.customerName,
    required this.heldAt,
  });
}

class PosProvider extends ChangeNotifier {
  final PosApiService _posApiService = PosApiService();
  final OrderApiService _orderApiService = OrderApiService();

  List<Product> _products = [];
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Cart State
  final List<CartItem> _cart = [];
  String _customerName = 'Walk-in Customer';
  int? _customerId;
  double _cartDiscountPercentage = 0.0;
  final double _defaultTaxPercentage = 5.0;

  // Held Orders
  final List<HeldOrder> _heldOrders = [];

  // Last Completed Order (for printing receipt)
  PosOrder? _lastCompletedOrder;

  List<Product> get products => _products;
  List<Map<String, dynamic>> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CartItem> get cart => _cart;
  String get customerName => _customerName;
  int? get customerId => _customerId;
  double get cartDiscountPercentage => _cartDiscountPercentage;
  List<HeldOrder> get heldOrders => _heldOrders;
  PosOrder? get lastCompletedOrder => _lastCompletedOrder;

  // Cart Calculations
  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get cartDiscountAmount => subtotal * (_cartDiscountPercentage / 100.0);
  double get taxableSubtotal => subtotal - cartDiscountAmount;
  double get taxAmount => taxableSubtotal * (_defaultTaxPercentage / 100.0);
  double get grandTotal => taxableSubtotal + taxAmount;
  int get itemCount => _cart.fold(0, (sum, item) => sum + item.quantity.toInt());

  Future<void> fetchProducts(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _posApiService.getProducts(token, search: _searchQuery, categoryId: _selectedCategoryId);
      _categories = await _posApiService.getCategories(token);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query, String? token) {
    _searchQuery = query;
    fetchProducts(token);
  }

  void selectCategory(int? catId, String? token) {
    _selectedCategoryId = catId;
    fetchProducts(token);
  }

  Future<bool> scanBarcode(String? token, String barcode) async {
    try {
      final product = await _posApiService.getProductByBarcode(token, barcode);
      addToCart(product);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity + 1 > product.stockQuantity) {
        _errorMessage = 'Cannot add more. Available stock: ${product.stockQuantity}';
        notifyListeners();
        return;
      }
      _cart[index].quantity += 1;
    } else {
      if (product.stockQuantity < 1) {
        _errorMessage = 'Product "${product.name}" is out of stock!';
        notifyListeners();
        return;
      }
      _cart.add(CartItem(product: product, quantity: 1.0, tax: product.taxPercentage));
    }
    _errorMessage = null;
    notifyListeners();
  }

  void updateQuantity(int productId, double newQty) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        if (newQty > _cart[index].product.stockQuantity) {
          _errorMessage = 'Quantity exceeds available stock (${_cart[index].product.stockQuantity})';
          notifyListeners();
          return;
        }
        _cart[index].quantity = newQty;
      }
      _errorMessage = null;
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _cartDiscountPercentage = 0.0;
    _customerName = 'Walk-in Customer';
    _customerId = null;
    notifyListeners();
  }

  void setCustomer(String name, int? id) {
    _customerName = name;
    _customerId = id;
    notifyListeners();
  }

  void setCartDiscount(double discountPercent) {
    _cartDiscountPercentage = discountPercent.clamp(0.0, 100.0);
    notifyListeners();
  }

  void holdCurrentOrder() {
    if (_cart.isEmpty) return;
    final heldId = "HOLD-${DateTime.now().millisecondsSinceEpoch % 10000}";
    _heldOrders.add(HeldOrder(
      id: heldId,
      label: "$heldId (${_cart.length} items - \$$grandTotal)",
      items: List.from(_cart),
      customerName: _customerName,
      heldAt: DateTime.now(),
    ));
    clearCart();
  }

  void resumeHeldOrder(HeldOrder heldOrder) {
    _cart.clear();
    _cart.addAll(heldOrder.items);
    _customerName = heldOrder.customerName ?? 'Walk-in Customer';
    _heldOrders.removeWhere((o) => o.id == heldOrder.id);
    notifyListeners();
  }

  Future<PosOrder?> checkout(
    String? token, {
    required String paymentMethod,
    required double amountReceived,
    String? referenceNumber,
  }) async {
    if (_cart.isEmpty) {
      _errorMessage = 'Cart is empty. Add products before payment.';
      notifyListeners();
      return null;
    }

    if (paymentMethod == 'Cash' && amountReceived < grandTotal) {
      _errorMessage = 'Amount received is less than total amount due.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderData = {
        'customerId': _customerId,
        'customerName': _customerName,
        'subtotal': subtotal,
        'discountAmount': cartDiscountAmount,
        'taxAmount': taxAmount,
        'grandTotal': grandTotal,
        'amountReceived': amountReceived,
        'changeAmount': (amountReceived - grandTotal).clamp(0.0, double.infinity),
        'paymentMethod': paymentMethod,
        'referenceNumber': referenceNumber,
        'items': _cart.map((item) => item.toJson()).toList(),
        'payments': [
          {
            'payment_method': paymentMethod,
            'amount': grandTotal,
            'reference_number': referenceNumber,
          }
        ],
      };

      final completedOrder = await _orderApiService.createOrder(token, orderData);
      _lastCompletedOrder = completedOrder;
      clearCart();
      await fetchProducts(token); // refresh product stocks
      return completedOrder;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
