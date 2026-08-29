import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class ReceiptDialog extends StatelessWidget {
  final PosOrder order;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String receiptFooter;

  const ReceiptDialog({
    super.key,
    required this.order,
    this.storeName = 'ERP Mart Store',
    this.storeAddress = '123 Commerce Way, Tech City',
    this.storePhone = '+1 (555) 019-2831',
    this.receiptFooter = 'Thank you for shopping with us! Please come again.',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Receipt Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 10),

              // Printable Thermal Receipt Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(storeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(storeAddress, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
                    Text('Tel: $storePhone', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #: ${order.orderNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(order.paymentMethod ?? 'Cash', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${_formatDate(order.createdAt)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('Status: ${order.orderStatus.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),

                    // Items List Header
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 3, child: Text('Item', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('Total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 8),

                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 3, child: Text(item.productName, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Expanded(flex: 1, child: Text('${item.quantity.toStringAsFixed(0)}x', style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: Text('\$${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                          ],
                        ),
                      );
                    }),

                    const Divider(thickness: 1),

                    _buildSummaryRow('Subtotal:', '\$${order.subtotal.toStringAsFixed(2)}'),
                    if (order.discountAmount > 0)
                      _buildSummaryRow('Discount:', '-\$${order.discountAmount.toStringAsFixed(2)}'),
                    _buildSummaryRow('Tax:', '+\$${order.taxAmount.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GRAND TOTAL:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('\$${order.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5))),
                      ],
                    ),

                    if (order.paymentMethod == 'Cash') ...[
                      const SizedBox(height: 4),
                      _buildSummaryRow('Paid Received:', '\$${order.amountReceived.toStringAsFixed(2)}'),
                      _buildSummaryRow('Change Returned:', '\$${order.changeAmount.toStringAsFixed(2)}'),
                    ],

                    const SizedBox(height: 14),
                    Text(receiptFooter, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ErpToast.showInfo(
                          context,
                          'Sent to Thermal Receipt Printer!',
                          title: 'Printing Receipt',
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print Receipt'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
