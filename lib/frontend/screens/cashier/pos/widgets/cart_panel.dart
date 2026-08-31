import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/pos_provider.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/receipt_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class CartPanel extends StatefulWidget {
  const CartPanel({super.key});

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  String _selectedPaymentMethod = 'Cash';
  final TextEditingController _amountReceivedController = TextEditingController(
    text: '0',
  );

  @override
  void dispose() {
    _amountReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final double amountReceived =
        double.tryParse(_amountReceivedController.text) ?? 0.0;
    final double changeAmount = (amountReceived - posProvider.grandTotal).clamp(
      0.0,
      double.infinity,
    );

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
      child: Column(
        children: [
          // 1. Customer Selection Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: posProvider.customerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B),
                        ),
                        items: {
                          'Walk-in Customer',
                          'John Doe (Regular)',
                          'Ahmed Al-Mansoor',
                          posProvider.customerName,
                        }.map((name) => DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) posProvider.setCustomer(val, null);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.search,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Cart Table Header
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Discount',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    'Action',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Cart Items / Table Body
          Expanded(
            child: posProvider.cart.isEmpty
                ? const Center(
                    child: Text(
                      'No items in cart',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: posProvider.cart.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final item = posProvider.cart[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '\$${item.product.sellingPrice.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () => posProvider.updateQuantity(
                                      item.product.id,
                                      item.quantity - 1,
                                    ),
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Text(
                                      item.quantity.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => posProvider.updateQuantity(
                                      item.product.id,
                                      item.quantity + 1,
                                    ),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '\$${item.discount.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '\$${item.total.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    posProvider.removeItem(item.product.id),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 4. Action Row Below Table: Clear Cart & Total Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: posProvider.cart.isEmpty
                      ? null
                      : posProvider.clearCart,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF93C5FD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16 , color: Color(0xFF2563EB)),
                  label: const Text(
                    'Clear Cart',
                    style: TextStyle(fontSize: 12 , fontWeight: FontWeight.bold , color: Color(0xFF2563EB)),
                  ),
                ),
                Text(
                  'Total Items: ${posProvider.cart.length} (${posProvider.itemCount})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 5. Two-Column Bottom Split Section: Order Summary (Left) & Payment Method (Right)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Order Summary
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryRow(
                          'Subtotal',
                          '\$${posProvider.subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Discount',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              height: 26,
                              child: TextField(
                                style: const TextStyle(fontSize: 11),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 0,
                                  ),
                                  prefixText: '\$ ',
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
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
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          'Tax (VAT 10%)',
                          '\$${posProvider.taxAmount.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Shipping', '\$0.00'),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Other Charges', '\$0.00'),
                        const Divider(height: 16, color: Color(0xFFE2E8F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '\$${posProvider.grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Right Column: Payment Method
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 2x3 Grid of Payment Method Buttons
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          childAspectRatio: 1.3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          children: [
                            _buildPaymentTile(
                              'Cash',
                              Icons.money_rounded,
                              const Color(0xFF2563EB),
                            ),
                            _buildPaymentTile(
                              'Card',
                              Icons.credit_card,
                              const Color(0xFF2563EB),
                            ),
                            _buildPaymentTile(
                              'UPI',
                              Icons.electric_bolt,
                              const Color(0xFF2563EB),
                            ),
                            _buildPaymentTile(
                              'Bank Transfer',
                              Icons.account_balance,
                              const Color(0xFF2563EB),
                            ),
                            _buildPaymentTile(
                              'Credit',
                              Icons.credit_score,
                              const Color(0xFF2563EB),
                            ),
                            _buildPaymentTile(
                              'Wallet',
                              Icons.account_balance_wallet,
                              const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Amount Received input row
                        Row(
                          children: [
                            const Text(
                              'Amount Received',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: _amountReceivedController,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 0,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.attach_money,
                                      size: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Change calculation pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '\$${changeAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. Bottom Action Buttons Row (4 wide buttons)
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              children: [
                // Bill Hold (Soft Yellow)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: posProvider.cart.isEmpty
                        ? null
                        : () {
                            posProvider.holdCurrentOrder();
                            ErpToast.showWarning(
                              context,
                              'Order Held Successfully',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF3C7),
                      foregroundColor: const Color(0xFFD97706),
                      disabledBackgroundColor:
                          const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                      disabledForegroundColor:
                          const Color(0xFFD97706).withValues(alpha: 0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.pause, size: 16),
                    label: const Text(
                      'Bill Hold',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Save Draft (Soft Light Blue)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: posProvider.cart.isEmpty
                        ? null
                        : () {
                            posProvider.holdCurrentOrder();
                            ErpToast.showInfo(
                              context,
                              'Order Saved as Draft',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDBEAFE),
                      foregroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor:
                          const Color(0xFFDBEAFE).withValues(alpha: 0.5),
                      disabledForegroundColor:
                          const Color(0xFF2563EB).withValues(alpha: 0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text(
                      'Save Draft',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Print Receipt (Soft Light Purple)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (posProvider.cart.isEmpty && posProvider.lastCompletedOrder == null)
                        ? null
                        : () {
                            final orderToPrint = posProvider.lastCompletedOrder ??
                                PosOrder(
                                  id: 0,
                                  orderNumber: 'DRAFT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                                  cashierId: 1,
                                  customerName: posProvider.customerName,
                                  subtotal: posProvider.subtotal,
                                  discountAmount: posProvider.cartDiscountAmount,
                                  taxAmount: posProvider.taxAmount,
                                  grandTotal: posProvider.grandTotal,
                                  paymentMethod: _selectedPaymentMethod,
                                  amountReceived: amountReceived,
                                  changeAmount: changeAmount,
                                  items: posProvider.cart
                                      .map((i) => PosOrderItem(
                                            id: 0,
                                            orderId: 0,
                                            productId: 0,
                                            productName: i.product.name,
                                            quantity: i.quantity,
                                            unitPrice: i.product.sellingPrice,
                                            discountAmount: i.discountAmount,
                                            taxAmount: i.taxAmount,
                                            totalAmount: i.total,
                                          ))
                                      .toList(),
                                  createdAt: DateTime.now(),
                                );

                            showDialog(
                              context: context,
                              builder: (_) => ReceiptDialog(order: orderToPrint),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E8FF),
                      foregroundColor: const Color(0xFF9333EA),
                      disabledBackgroundColor:
                          const Color(0xFFF3E8FF).withValues(alpha: 0.5),
                      disabledForegroundColor:
                          const Color(0xFF9333EA).withValues(alpha: 0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Complete Sale (Vibrant Solid Green)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: posProvider.cart.isEmpty || posProvider.isLoading
                        ? null
                        : () async {
                            final effectiveAmount = _selectedPaymentMethod == 'Cash'
                                ? amountReceived
                                : posProvider.grandTotal;

                            final order = await posProvider.checkout(
                              authProvider.token,
                              paymentMethod: _selectedPaymentMethod,
                              amountReceived: effectiveAmount,
                            );

                            if (order != null && context.mounted) {
                              ErpToast.showSuccess(
                                context,
                                'Sale Completed! Order #${order.orderNumber}',
                              );
                              showDialog(
                                context: context,
                                builder: (_) => ReceiptDialog(order: order),
                              );
                            } else if (posProvider.errorMessage != null && context.mounted) {
                              ErpToast.showError(
                                context,
                                posProvider.errorMessage!,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: posProvider.isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 16),
                    label: Text(
                      posProvider.isLoading ? 'Processing...' : 'Complete Sale',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = label),
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
