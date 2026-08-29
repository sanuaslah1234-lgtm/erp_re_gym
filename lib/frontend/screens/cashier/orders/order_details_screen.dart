import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/cashier/order_provider.dart';
import 'package:erp_software/frontend/screens/cashier/pos/widgets/receipt_dialog.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final PosOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Order Details - ${order.orderNumber}'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ReceiptDialog(order: order),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildRow('Order Number', order.orderNumber),
                    const Divider(),
                    _buildRow('Customer', order.customerName ?? 'Walk-in'),
                    const Divider(),
                    _buildRow('Cashier ID', 'Cashier #${order.cashierId}'),
                    const Divider(),
                    _buildRow('Payment Method', order.paymentMethod ?? 'Cash'),
                    const Divider(),
                    _buildRow('Order Status', order.orderStatus.toUpperCase()),
                    const Divider(),
                    _buildRow('Date & Time', order.createdAt?.toString() ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Purchased Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Items Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final item = order.items[i];
                    return ListTile(
                      title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.quantity.toStringAsFixed(0)} x \$${item.unitPrice.toStringAsFixed(2)}'),
                      trailing: Text('\$${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Financial Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                    _buildRow('Discount', '-\$${order.discountAmount.toStringAsFixed(2)}'),
                    _buildRow('Tax', '+\$${order.taxAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('\$${order.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (order.orderStatus == 'paid')
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: orderProvider.isLoading
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Cancel Order?'),
                              content: const Text('This will cancel the order and restore product inventory in PostgreSQL.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel Order')),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            final success = await orderProvider.cancelOrder(authProvider.token, order.id);
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Order & Restore Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
