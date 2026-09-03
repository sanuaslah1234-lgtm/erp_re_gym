import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/config/app_config.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/pos_provider.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/receipt_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class CartPanel extends StatefulWidget {
  final VoidCallback? onBack;
  const CartPanel({super.key, this.onBack});

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  String _selectedPaymentMethod = 'Cash';
  final TextEditingController _amountReceivedController = TextEditingController(
    text: '0',
  );
  bool _amountAutoFilled = false;
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/customers'),
        headers: {
          'Content-Type': 'application/json',
          if (auth.token != null) 'Authorization': 'Bearer ${auth.token}',
        },
      ).timeout(const Duration(seconds: 5));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final data = body['data'];
        if (data is List) {
          setState(() => _customers = data.cast<Map<String, dynamic>>());
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Auto-fill amount received with grand total when cart changes and payment is Cash
    if (_selectedPaymentMethod == 'Cash' && !_amountAutoFilled && posProvider.grandTotal > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_amountAutoFilled) {
          _amountReceivedController.text = posProvider.grandTotal.toStringAsFixed(2);
          _amountAutoFilled = true;
          setState(() {});
        }
      });
    }
    if (posProvider.cart.isEmpty) {
      _amountAutoFilled = false;
    }

    final double amountReceived =
        double.tryParse(_amountReceivedController.text) ?? 0.0;
    final double changeAmount = (amountReceived - posProvider.grandTotal).clamp(
      0.0,
      double.infinity,
    );

    // Build clean, deduplicated customer dropdown items
    final customerItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'Walk-in Customer',
        child: Text('Walk-in Customer'),
      ),
    ];
    final seenCustomerNames = <String>{'Walk-in Customer'};
    for (final c in _customers) {
      final name = c['name']?.toString().trim();
      if (name != null && name.isNotEmpty && !seenCustomerNames.contains(name)) {
        seenCustomerNames.add(name);
        final phone = c['phone']?.toString().trim();
        final label = (phone != null && phone.isNotEmpty) ? '$name ($phone)' : name;
        customerItems.add(
          DropdownMenuItem(
            value: name,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        );
      }
    }

    final currentCustName = posProvider.customerName;
    final selectedCustomerValue = seenCustomerNames.contains(currentCustName)
        ? currentCustName
        : 'Walk-in Customer';

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Back button (mobile only)
            if (isMobile && widget.onBack != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF2563EB)),
                  label: const Text('Back to Products', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                ),
              ),

            // 1. Customer Selection Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCustomerValue,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                        items: customerItems,
                        onChanged: (val) {
                          if (val != null) {
                            final match = _customers.firstWhere(
                              (c) => c['name']?.toString() == val,
                              orElse: () => {},
                            );
                            final id = match.isNotEmpty ? int.tryParse(match['id'].toString()) : null;
                            posProvider.setCustomer(val, id);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Cart Table Header (Desktop Only)
            if (!isMobile)
              Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  children: [
                    SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                    Expanded(flex: 3, child: Text('Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                    Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                    Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                    Expanded(flex: 2, child: Text('Discount', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                    Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                    SizedBox(width: 36, child: Text('Action', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                  ],
                ),
              ),

            // 3. Cart Items / Table Body
            if (posProvider.cart.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No items in cart',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: posProvider.cart.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final item = posProvider.cart[index];
                  if (isMobile) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${index + 1}.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '\$${item.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${item.product.sellingPrice.toStringAsFixed(2)} each',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => posProvider.updateQuantity(item.product.id, item.quantity - 1),
                                    child: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF64748B)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      item.quantity.toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => posProvider.updateQuantity(item.product.id, item.quantity + 1),
                                    child: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF2563EB)),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () => posProvider.removeItem(item.product.id),
                                    child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                        Expanded(flex: 3, child: Text(item.product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Expanded(flex: 2, child: Text('\$${item.product.sellingPrice.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(onTap: () => posProvider.updateQuantity(item.product.id, item.quantity - 1), child: const Icon(Icons.remove_circle_outline, size: 16, color: Color(0xFF64748B))),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text(item.quantity.toStringAsFixed(0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              InkWell(onTap: () => posProvider.updateQuantity(item.product.id, item.quantity + 1), child: const Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Expanded(flex: 2, child: Text('\$${item.discount.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                        Expanded(flex: 2, child: Text('\$${item.total.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                        SizedBox(width: 36, child: IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent), onPressed: () => posProvider.removeItem(item.product.id))),
                      ],
                    ),
                  );
                },
              ),

            // 4. Action Row Below Table: Clear Cart & Total Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: posProvider.cart.isEmpty ? null : posProvider.clearCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF93C5FD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 15, color: Color(0xFF2563EB)),
                    label: const Text('Clear Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ),
                  Text(
                    'Total Items: ${posProvider.cart.length} (${posProvider.itemCount})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // 5. Order Summary & Payment Method Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: isMobile
                  ? Column(
                      children: [
                        _buildOrderSummaryWidget(posProvider),
                        const SizedBox(height: 10),
                        _buildPaymentMethodWidget(posProvider, changeAmount),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildOrderSummaryWidget(posProvider)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPaymentMethodWidget(posProvider, changeAmount)),
                      ],
                    ),
            ),

            // 6. Bottom Action Buttons Row
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 12),
              child: isMobile
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildBillHoldBtn(posProvider)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildSaveDraftBtn(posProvider)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildPrintReceiptBtn(posProvider)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildCompleteSaleBtn(posProvider, authProvider, amountReceived)),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildBillHoldBtn(posProvider)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildSaveDraftBtn(posProvider)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildPrintReceiptBtn(posProvider)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCompleteSaleBtn(posProvider, authProvider, amountReceived)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryWidget(PosProvider posProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          _buildSummaryRow('Subtotal', '\$${posProvider.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              SizedBox(
                width: 60,
                height: 24,
                child: TextField(
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    prefixText: '\$ ',
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final disc = double.tryParse(val) ?? 0.0;
                    posProvider.setCartDiscount(disc);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildSummaryRow('Tax (VAT 10%)', '\$${posProvider.taxAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _buildSummaryRow('Shipping', '\$0.00'),
          const SizedBox(height: 4),
          _buildSummaryRow('Other Charges', '\$0.00'),
          const Divider(height: 12, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text(
                '\$${posProvider.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodWidget(PosProvider posProvider, double changeAmount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 2.1,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              _buildPaymentTile('Cash', Icons.money_rounded, const Color(0xFF2563EB)),
              _buildPaymentTile('Card', Icons.credit_card, const Color(0xFF2563EB)),
              _buildPaymentTile('UPI', Icons.electric_bolt, const Color(0xFF2563EB)),
              _buildPaymentTile('Bank Transfer', Icons.account_balance, const Color(0xFF2563EB)),
              _buildPaymentTile('Credit', Icons.credit_score, const Color(0xFF2563EB)),
              _buildPaymentTile('Wallet', Icons.account_balance_wallet, const Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Amount Received', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _amountReceivedController,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      prefixIcon: const Icon(Icons.attach_money, size: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Change', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  '\$${changeAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillHoldBtn(PosProvider posProvider) {
    return ElevatedButton.icon(
      onPressed: posProvider.cart.isEmpty
          ? null
          : () {
              posProvider.holdCurrentOrder();
              ErpToast.showWarning(context, 'Order Held Successfully');
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFEF3C7),
        foregroundColor: const Color(0xFFD97706),
        disabledBackgroundColor: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
        disabledForegroundColor: const Color(0xFFD97706).withValues(alpha: 0.5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.pause, size: 15),
      label: const Text('Bill Hold', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSaveDraftBtn(PosProvider posProvider) {
    return ElevatedButton.icon(
      onPressed: posProvider.cart.isEmpty
          ? null
          : () {
              posProvider.holdCurrentOrder();
              ErpToast.showInfo(context, 'Order Saved as Draft');
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDBEAFE),
        foregroundColor: const Color(0xFF2563EB),
        disabledBackgroundColor: const Color(0xFFDBEAFE).withValues(alpha: 0.5),
        disabledForegroundColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.save_outlined, size: 15),
      label: const Text('Save Draft', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPrintReceiptBtn(PosProvider posProvider) {
    return ElevatedButton.icon(
      onPressed: posProvider.lastCompletedOrder == null
          ? null
          : () {
              showDialog(
                context: context,
                builder: (_) => ReceiptDialog(order: posProvider.lastCompletedOrder!),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3E8FF),
        foregroundColor: const Color(0xFF9333EA),
        disabledBackgroundColor: const Color(0xFFF3E8FF).withValues(alpha: 0.5),
        disabledForegroundColor: const Color(0xFF9333EA).withValues(alpha: 0.5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.print_outlined, size: 15),
      label: const Text('Print Receipt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCompleteSaleBtn(PosProvider posProvider, AuthProvider authProvider, double amountReceived) {
    return ElevatedButton.icon(
      onPressed: posProvider.cart.isEmpty || posProvider.isLoading
          ? null
          : () async {
              final effectiveAmount = _selectedPaymentMethod == 'Cash' ? amountReceived : posProvider.grandTotal;
              final order = await posProvider.checkout(
                authProvider.token,
                paymentMethod: _selectedPaymentMethod,
                amountReceived: effectiveAmount,
              );
              if (!mounted) return;
              if (order != null) {
                ErpToast.showSuccess(context, 'Sale Completed! Order #${order.orderNumber}');
                showDialog(
                  context: context,
                  builder: (_) => ReceiptDialog(order: order),
                );
              } else if (posProvider.errorMessage != null) {
                ErpToast.showError(context, posProvider.errorMessage!);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: posProvider.isLoading
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.check, size: 15),
      label: Text(
        posProvider.isLoading ? 'Processing...' : 'Complete Sale',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTile(String label, IconData icon, Color activeColor) {
    final isSelected = _selectedPaymentMethod == label;

    return InkWell(                    onTap: () {
                      final pp = Provider.of<PosProvider>(context, listen: false);
                      setState(() {
                        _selectedPaymentMethod = label;
                        if (label == 'Cash' && pp.grandTotal > 0) {
                          _amountReceivedController.text = pp.grandTotal.toStringAsFixed(2);
                          _amountAutoFilled = true;
                        }
                      });
                    },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : const Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
