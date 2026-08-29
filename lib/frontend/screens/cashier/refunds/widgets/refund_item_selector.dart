import 'package:flutter/material.dart';
import 'package:erp_software/core/models/cashier/pos_order.dart';
import 'package:erp_software/theme/app_colors.dart';

class RefundItemSelector extends StatelessWidget {
  final PosOrder order;
  final Map<int, double> refundQuantities;
  final Function(int itemId, double newQty, double maxQty) onQuantityChanged;

  const RefundItemSelector({
    super.key,
    required this.order,
    required this.refundQuantities,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Items: ${order.orderNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('Total Paid: \$${order.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, _) => const Divider(color: AppColors.border),
            itemBuilder: (ctx, i) {
              final item = order.items[i];
              final currentRefundQty = refundQuantities[item.id] ?? 0.0;
              final unitRefundPrice = item.quantity > 0 ? item.totalAmount / item.quantity : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                          Text('Purchased: ${item.quantity.toStringAsFixed(0)} • Unit Price: \$${unitRefundPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
                          onPressed: currentRefundQty > 0
                              ? () => onQuantityChanged(item.id, currentRefundQty - 1, item.quantity)
                              : null,
                        ),
                        Text(
                          currentRefundQty.toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          onPressed: currentRefundQty < item.quantity
                              ? () => onQuantityChanged(item.id, currentRefundQty + 1, item.quantity)
                              : null,
                        ),
                      ],
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
}
