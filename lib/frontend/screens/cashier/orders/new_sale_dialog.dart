import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:erp_software/core/config/app_config.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/services/cashier/order_api_service.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class NewSaleDialog extends StatefulWidget {
  const NewSaleDialog({super.key});

  @override
  State<NewSaleDialog> createState() => _NewSaleDialogState();
}

class _NewSaleDialogState extends State<NewSaleDialog> {
  final OrderApiService _orderApiService = OrderApiService();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _receivedCtrl = TextEditingController();
  
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _selectedPaymentMethod = 'Cash';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/products').replace(
        queryParameters: {
          if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
        },
      );
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (auth.token != null) 'Authorization': 'Bearer ${auth.token}',
        },
      ).timeout(const Duration(seconds: 5));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        final List data = body['data'] ?? [];
        setState(() {
          _products = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to load products');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    final existingIndex = _cartItems.indexWhere((item) => item['product_id'] == product['id']);
    if (existingIndex >= 0) {
      setState(() {
        final existing = _cartItems[existingIndex];
        _cartItems[existingIndex] = {
          ...existing,
          'quantity': (existing['quantity'] as int) + 1,
        };
      });
    } else {
      final price = (product['selling_price'] ?? product['purchase_price'] ?? 0).toDouble();
      setState(() {
        _cartItems.add({
          'product_id': product['id'],
          'product_name': product['name'] ?? 'Unknown',
          'unit_price': price,
          'quantity': 1,
          'discount_amount': 0.0,
          'tax_amount': 0.0,
          'total_amount': price,
        });
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  void _updateCartQuantity(int index, int delta) {
    setState(() {
      final item = _cartItems[index];
      final newQty = (item['quantity'] as int) + delta;
      if (newQty <= 0) {
        _cartItems.removeAt(index);
      } else {
        final price = (item['unit_price'] as double);
        _cartItems[index] = {
          ...item,
          'quantity': newQty,
          'total_amount': price * newQty,
        };
      }
    });
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + (item['total_amount'] as double));
  double get _totalDiscount => _cartItems.fold(0.0, (sum, item) => sum + (item['discount_amount'] as double));
  double get _totalTax => _cartItems.fold(0.0, (sum, item) => sum + (item['tax_amount'] as double));
  double get _grandTotal => _subtotal - _totalDiscount + _totalTax;

  Future<void> _submitSale() async {
    if (_cartItems.isEmpty) {
      ErpToast.showError(context, 'Cart is empty. Add products first.');
      return;
    }
    
    setState(() => _isSubmitting = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final orderData = {
        'subtotal': _subtotal,
        'discountAmount': _totalDiscount,
        'taxAmount': _totalTax,
        'grandTotal': _grandTotal,
        'amountReceived': double.tryParse(_receivedCtrl.text) ?? _grandTotal,
        'changeAmount': (double.tryParse(_receivedCtrl.text) ?? _grandTotal) - _grandTotal,
        'paymentMethod': _selectedPaymentMethod,
        'items': _cartItems.map((item) => {
          'productId': item['product_id'],
          'productName': item['product_name'],
          'quantity': item['quantity'],
          'unitPrice': item['unit_price'],
          'discountAmount': item['discount_amount'],
          'taxAmount': item['tax_amount'],
          'totalAmount': item['total_amount'],
        }).toList(),
        'payments': [
          {
            'paymentMethod': _selectedPaymentMethod,
            'amount': _grandTotal,
          }
        ],
      };

      final order = await _orderApiService.createOrder(auth.token, orderData);
      if (mounted) {
        Navigator.pop(context, true);
        ErpToast.showSuccess(context, 'Sale #${order.orderNumber} created successfully!');
      }
    } catch (e) {
      if (mounted) {
        ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.point_of_sale, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 10),
                    Text('New Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 20),
            
            Expanded(
              child: Row(
                children: [
                  // Left: Product Browser
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search
                        TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh, size: 18),
                              onPressed: _loadProducts,
                            ),
                          ),
                          onSubmitted: (_) => _loadProducts(),
                        ),
                        const SizedBox(height: 10),
                        
                        // Product List
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _error != null
                                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                                  : _products.isEmpty
                                      ? const Center(child: Text('No products found'))
                                      : ListView.builder(
                                          itemCount: _products.length,
                                          itemBuilder: (context, index) {
                                            final p = _products[index];
                                            final stock = (p['stock_quantity'] ?? 0).toInt();
                                            final price = (p['selling_price'] ?? 0).toDouble();
                                            return Card(
                                              margin: const EdgeInsets.only(bottom: 6),
                                              child: ListTile(
                                                dense: true,
                                                title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                                subtitle: Text('\$${price.toStringAsFixed(2)}  •  Stock: $stock', style: const TextStyle(fontSize: 11)),
                                                trailing: IconButton(
                                                  icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB)),
                                                  onPressed: stock > 0 ? () => _addToCart(p) : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  const VerticalDivider(width: 1),
                  const SizedBox(width: 16),
                  
                  // Right: Cart
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cart (${_cartItems.length} items)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        
                        Expanded(
                          child: _cartItems.isEmpty
                              ? const Center(child: Text('Add products from the left', style: TextStyle(color: Colors.grey, fontSize: 12)))
                              : ListView.builder(
                                  itemCount: _cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _cartItems[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item['product_name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                                Text('\$${(item['unit_price'] as double).toStringAsFixed(2)} each', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.red),
                                                onPressed: () => _updateCartQuantity(index, -1),
                                              ),
                                              Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                icon: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF2563EB)),
                                                onPressed: () => _updateCartQuantity(index, 1),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 4),
                                          Text('\$${(item['total_amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                            icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                                            onPressed: () => _removeFromCart(index),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        
                        const Divider(height: 20),
                        
                        // Payment
                        Row(
                          children: [
                            const Text('Payment: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedPaymentMethod,
                                isDense: true,
                                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Card', child: Text('Card', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'UPI', child: Text('UPI', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (v) => setState(() => _selectedPaymentMethod = v ?? 'Cash'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        if (_selectedPaymentMethod == 'Cash')
                          TextField(
                            controller: _receivedCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount Received',
                              isDense: true,
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                          ),
                        const SizedBox(height: 10),
                        
                        // Totals
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text('Subtotal', style: TextStyle(fontSize: 12)),
                                Text('\$${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ]),
                              const SizedBox(height: 4),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text('Grand Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('\$${_grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Submit
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting || _cartItems.isEmpty ? null : _submitSale,
                            icon: _isSubmitting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check, size: 18),
                            label: Text(_isSubmitting ? 'Processing...' : 'Complete Sale'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _receivedCtrl.dispose();
    super.dispose();
  }
}
