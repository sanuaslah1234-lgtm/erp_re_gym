import 'dart:async';
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
  final int? customerId;
  final DateTime heldAt;

  HeldOrder({
    required this.id,
    required this.label,
    required this.items,
    this.customerName,
    this.customerId,
    required this.heldAt,
  });
}

class PosProvider extends ChangeNotifier {
  final PosApiService _posApiService = PosApiService();
  final OrderApiService _orderApiService = OrderApiService();

  // Products / Filters
  List<Product> _products = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _brands = [];
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _warningMessage;

  // Cart State
  final List<CartItem> _cart = [];
  String _customerName = 'Walk-in Customer';
  int? _customerId;
  double _cartDiscountPercentage = 0.0;
  final double _defaultTaxPercentage = 5.0;
  double _shippingCharge = 0.0;
  double _otherCharges = 0.0;

  // Held Orders
  final List<HeldOrder> _heldOrders = [];

  // Last Completed Order
  PosOrder? _lastCompletedOrder;

  // Search debounce
  Timer? _debounceTimer;

  // --- Getters ---
  List<Product> get products => _products;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get brands => _brands;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedBrandId => _selectedBrandId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get warningMessage => _warningMessage;

  List<CartItem> get cart => _cart;
  String get customerName => _customerName;
  int? get customerId => _customerId;
  double get cartDiscountPercentage => _cartDiscountPercentage;
  double get shippingCharge => _shippingCharge;
  double get otherCharges => _otherCharges;
  List<HeldOrder> get heldOrders => _heldOrders;
  PosOrder? get lastCompletedOrder => _lastCompletedOrder;

  // --- Calculations ---
  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get cartDiscountAmount => subtotal * (_cartDiscountPercentage / 100.0);
  double get taxableSubtotal => subtotal - cartDiscountAmount;
  double get taxAmount => taxableSubtotal * (_defaultTaxPercentage / 100.0);
  double get grandTotal => taxableSubtotal + taxAmount + _shippingCharge + _otherCharges;
  int get itemCount => _cart.fold(0, (sum, item) => sum + item.quantity.toInt());

  // --- Products ---
  Future<void> fetchProducts(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _posApiService.getProducts(
        token,
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
      );
      _categories = await _posApiService.getCategories(token);
      _brands = await _posApiService.getBrands(token);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query, String? token) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchProducts(token);
    });
  }

  void selectCategory(int? catId, String? token) {
    _selectedCategoryId = catId;
    fetchProducts(token);
  }

  void selectBrand(int? brandId, String? token) {
    _selectedBrandId = brandId;
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

  // --- Cart Operations ---
  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      // Check stock before increasing
      final currentQty = _cart[index].quantity;
      if (currentQty >= product.stockQuantity && product.stockQuantity > 0) {
        _warningMessage = 'Only ${product.stockQuantity.toInt()} available in stock for "${product.name}"';
        notifyListeners();
        return;
      }
      _cart[index].quantity += 1;
    } else {
      _cart.add(CartItem(
        product: product,
        quantity: 1.0,
        tax: product.taxPercentage,
      ));
      if (product.stockQuantity < 1) {
        _warningMessage = '"${product.name}" is out of stock — backorder item added';
      }
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

  void clearError() => _errorMessage = null;
  void clearWarning() => _warningMessage = null;

  void clearCart() {
    _cart.clear();
    _cartDiscountPercentage = 0.0;
    _shippingCharge = 0.0;
    _otherCharges = 0.0;
    _customerName = 'Walk-in Customer';
    _customerId = null;
    _warningMessage = null;
    notifyListeners();
  }

  // --- Customer ---
  void setCustomer(String name, int? id) {
    _customerName = name;
    _customerId = id;
    notifyListeners();
  }

  // --- Charges ---
  void setCartDiscount(double discountPercent) {
    _cartDiscountPercentage = discountPercent.clamp(0.0, 100.0);
    notifyListeners();
  }

  void setShipping(double amount) {
    _shippingCharge = amount.clamp(0.0, double.infinity);
    notifyListeners();
  }

  void setOtherCharges(double amount) {
    _otherCharges = amount.clamp(0.0, double.infinity);
    notifyListeners();
  }

  // --- Held Orders ---
  void holdCurrentOrder() {
    if (_cart.isEmpty) return;
    final heldId = "HOLD-${DateTime.now().millisecondsSinceEpoch % 10000}";
    _heldOrders.add(HeldOrder(
      id: heldId,
      label: "$heldId (${_cart.length} items - \$${grandTotal.toStringAsFixed(2)})",
      items: List.from(_cart),
      customerName: _customerName,
      customerId: _customerId,
      heldAt: DateTime.now(),
    ));
    clearCart();
    notifyListeners();
  }

  void resumeHeldOrder(HeldOrder heldOrder) {
    _cart.clear();
    _cart.addAll(heldOrder.items);
    _customerName = heldOrder.customerName ?? 'Walk-in Customer';
    _customerId = heldOrder.customerId;
    _heldOrders.removeWhere((o) => o.id == heldOrder.id);
    notifyListeners();
  }

  void removeHeldOrder(String heldId) {
    _heldOrders.removeWhere((o) => o.id == heldId);
    notifyListeners();
  }

  // --- Checkout ---
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
        'shippingCharge': _shippingCharge,
        'otherCharges': _otherCharges,
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
