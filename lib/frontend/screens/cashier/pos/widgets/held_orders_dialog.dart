import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/cashier/pos_provider.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:provider/provider.dart';

class HeldOrdersDialog extends StatelessWidget {
  const HeldOrdersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 550),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pause_circle_outline, color: Color(0xFFD97706), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Held Orders / Draft Bills',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '${posProvider.heldOrders.length} held order(s) available',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Expanded(
              child: posProvider.heldOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No held orders found',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click "Bill Hold" on the cart panel to hold an active bill',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: posProvider.heldOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final held = posProvider.heldOrders[index];
                        final itemCount = held.items.fold(0, (sum, i) => sum + i.quantity.toInt());
                        final total = held.items.fold(0.0, (sum, i) => sum + i.total);

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          held.id,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            held.customerName ?? 'Walk-in Customer',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$itemCount item(s) • Held at ${_formatTime(held.heldAt)}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      posProvider.resumeHeldOrder(held);
                                      Navigator.pop(context);
                                      ErpToast.showSuccess(context, 'Held Order Resumed');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.play_arrow, size: 14),
                                    label: const Text('Resume', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
