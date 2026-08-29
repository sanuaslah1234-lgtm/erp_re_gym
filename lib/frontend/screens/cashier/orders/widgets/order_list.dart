import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';

class OrderList extends StatelessWidget {
  final List<PosOrder> orders;
  final ValueChanged<PosOrder> onOrderTap;
  final ValueChanged<PosOrder> onPrintReceipt;

  const OrderList({
    super.key,
    required this.orders,
    required this.onOrderTap,
    required this.onPrintReceipt,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text('No sales orders found', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Invoice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(flex: 2, child: Text('Cashier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(flex: 2, child: Text('Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(flex: 2, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                SizedBox(width: 80, child: Text('Action', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
              ],
            ),
          ),

          // Table Data Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final order = orders[index];
              final dateStr = order.createdAt != null ? "${order.createdAt!.year}-${order.createdAt!.month.toString().padLeft(2, '0')}-${order.createdAt!.day.toString().padLeft(2, '0')}" : '2026-08-14';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    // Invoice Code
                    Expanded(
                      flex: 3,
                      child: Text(
                        order.orderNumber.startsWith('SO-') ? order.orderNumber : 'SO-${order.orderNumber.replaceAll(RegExp(r'[^0-9]'), '')}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),

                    // Customer Name
                    Expanded(
                      flex: 3,
                      child: Text(
                        order.customerName ?? 'Walk-in Customer',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                      ),
                    ),

                    // Cashier Name
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Admin',
                        style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                      ),
                    ),

                    // Date
                    Expanded(
                      flex: 2,
                      child: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),

                    // Payment Method
                    Expanded(
                      flex: 2,
                      child: Text(
                        order.paymentMethod ?? 'Cash',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                      ),
                    ),

                    // Status Badge
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: _buildStatusPill(order.orderStatus),
                      ),
                    ),

                    // Total Price Tag
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₹${order.grandTotal.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),

                    // Action Button (View)
                    SizedBox(
                      width: 80,
                      child: Center(
                        child: InkWell(
                          onTap: () => onOrderTap(order),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg = const Color(0xFFFEE2E2);
    Color text = const Color(0xFFDC2626);
    String label = 'Pending';

    final s = status.toLowerCase();
    if (s == 'paid' || s == 'completed') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
      label = 'Completed';
    } else if (s == 'refunded') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
      label = 'Refunded';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }
}

