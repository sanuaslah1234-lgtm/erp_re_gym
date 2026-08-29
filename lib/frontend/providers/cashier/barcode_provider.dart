import 'package:flutter/foundation.dart';
import 'package:erp_software/core/models/cashier/product.dart';
import 'package:erp_software/frontend/services/cashier/barcode_api_service.dart';
import 'package:erp_software/frontend/services/cashier/pos_api_service.dart';

class BarcodePrintItem {
  final Product product;
  int quantity;

  BarcodePrintItem({required this.product, this.quantity = 1});
}

class BarcodeProvider extends ChangeNotifier {
  final BarcodeApiService _barcodeApiService = BarcodeApiService();
  final PosApiService _posApiService = PosApiService();

  List<Product> _allProducts = [];
  final List<BarcodePrintItem> _selectedProducts = [];
  List<dynamic> _barcodeHistory = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Active Tab Index (0: Select Products, 1: Live Print Sheet)
  int _activeTab = 0;

  // Search & Category Filter State
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Selected Checkboxes for Products Table
  final Set<int> _checkedProductIds = {};

  // Print & Label Customization Settings
  String _paperPreset = '40 Labels Per Sheet (A4 - 52.5mm x 29.7mm)';
  String _storeHeader = 'ERP Enterprise Store';
  String _barcodeSymbology = 'CODE128 (Standard)';
  double _barcodeHeight = 38.0;
  double _barWidthMultiplier = 1.2;
  double _textSize = 11.0;

  // Display Fields Checkbox Toggles
  bool _showStoreHeader = true;
  bool _showProductName = true;
  bool _showSkuCode = true;
  bool _showPriceTag = true;
  bool _showBarcodeText = true;

  // Getters
  List<Product> get allProducts => _allProducts;
  List<BarcodePrintItem> get selectedProducts => _selectedProducts;
  List<dynamic> get barcodeHistory => _barcodeHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Set<int> get checkedProductIds => _checkedProductIds;

  String get paperPreset => _paperPreset;
  String get storeHeader => _storeHeader;
  String get barcodeSymbology => _barcodeSymbology;
  double get barcodeHeight => _barcodeHeight;
  double get barWidthMultiplier => _barWidthMultiplier;
  double get textSize => _textSize;

  bool get showStoreHeader => _showStoreHeader;
  bool get showProductName => _showProductName;
  bool get showSkuCode => _showSkuCode;
  bool get showPriceTag => _showPriceTag;
  bool get showBarcodeText => _showBarcodeText;

  // Filtered Products List
  List<Product> get filteredProducts {
    return _allProducts.where((p) {
      final matchesQuery = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.productCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.barcode != null && p.barcode!.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory = _selectedCategory == 'All' || p.categoryName == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  // Fetch Initial Data from Server
  Future<void> fetchProductsAndHistory(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await _posApiService.getProducts(token);
      _barcodeHistory = await _barcodeApiService.getBarcodeHistory(token);

      // Auto check all products by default for table view
      for (final p in _allProducts) {
        _checkedProductIds.add(p.id);
        if (!_selectedProducts.any((item) => item.product.id == p.id)) {
          _selectedProducts.add(BarcodePrintItem(product: p, quantity: 1));
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tab Selector
  void setActiveTab(int tabIndex) {
    _activeTab = tabIndex;
    notifyListeners();
  }

  // Filter Handlers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Checkbox Selection Handlers
  void toggleProductCheck(int productId, bool? checked) {
    if (checked == true) {
      _checkedProductIds.add(productId);
      final prod = _allProducts.firstWhere((p) => p.id == productId);
      addProductToPrint(prod, qty: 1);
    } else {
      _checkedProductIds.remove(productId);
      removeProduct(productId);
    }
    notifyListeners();
  }

  void toggleAllCheckboxes(bool? checked) {
    if (checked == true) {
      for (final p in filteredProducts) {
        _checkedProductIds.add(p.id);
        addProductToPrint(p, qty: 1);
      }
    } else {
      _checkedProductIds.clear();
      _selectedProducts.clear();
    }
    notifyListeners();
  }

  // Quick Preset Quantity Action (e.g. 1, 5, 10)
  void setPresetQty(int qty) {
    for (final item in _selectedProducts) {
      item.quantity = qty;
    }
    notifyListeners();
  }

  // Print Settings Setters
  void setPaperPreset(String val) {
    _paperPreset = val;
    notifyListeners();
  }

  void setStoreHeader(String val) {
    _storeHeader = val;
    notifyListeners();
  }

  void setBarcodeSymbology(String val) {
    _barcodeSymbology = val;
    notifyListeners();
  }

  void setBarcodeHeight(double val) {
    _barcodeHeight = val;
    notifyListeners();
  }

  void setBarWidthMultiplier(double val) {
    _barWidthMultiplier = val;
    notifyListeners();
  }

  void setTextSize(double val) {
    _textSize = val;
    notifyListeners();
  }

  // Display Fields Toggles
  void toggleShowStoreHeader(bool val) {
    _showStoreHeader = val;
    notifyListeners();
  }

  void toggleShowProductName(bool val) {
    _showProductName = val;
    notifyListeners();
  }

  void toggleShowSkuCode(bool val) {
    _showSkuCode = val;
    notifyListeners();
  }

  void toggleShowPriceTag(bool val) {
    _showPriceTag = val;
    notifyListeners();
  }

  void toggleShowBarcodeText(bool val) {
    _showBarcodeText = val;
    notifyListeners();
  }

  // Product Selection & Quantity Updates
  void addProductToPrint(Product product, {int qty = 1}) {
    final idx = _selectedProducts.indexWhere((item) => item.product.id == product.id);
    if (idx >= 0) {
      _selectedProducts[idx].quantity += qty;
    } else {
      _selectedProducts.add(BarcodePrintItem(product: product, quantity: qty));
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int qty) {
    final idx = _selectedProducts.indexWhere((item) => item.product.id == productId);
    if (idx >= 0) {
      if (qty <= 0) {
        _selectedProducts.removeAt(idx);
        _checkedProductIds.remove(productId);
      } else {
        _selectedProducts[idx].quantity = qty;
      }
      notifyListeners();
    }
  }

  void removeProduct(int productId) {
    _selectedProducts.removeWhere((item) => item.product.id == productId);
    _checkedProductIds.remove(productId);
    notifyListeners();
  }

  void clearPrintQueue() {
    _selectedProducts.clear();
    _checkedProductIds.clear();
    notifyListeners();
  }

  // Print Labels & Save Records to PostgreSQL Database
  Future<bool> printLabels(String? token) async {
    if (_selectedProducts.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      for (final item in _selectedProducts) {
        await _barcodeApiService.recordBarcodePrint(
          token,
          item.product.id,
          item.product.barcode ?? item.product.productCode,
          item.quantity,
        );
      }
      _barcodeHistory = await _barcodeApiService.getBarcodeHistory(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
