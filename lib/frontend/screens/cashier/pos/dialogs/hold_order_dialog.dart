import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/cashier/pos_provider.dart';
import 'package:erp_software/theme/app_colors.dart';

class HoldOrderDialog extends StatelessWidget {
  final List<HeldOrder> heldOrders;
  final ValueChanged<HeldOrder> onResumeOrder;

  const HoldOrderDialog({
    super.key,
    required this.heldOrders,
    required this.onResumeOrder,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Held POS Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      content: SizedBox(
        width: 400,
        child: heldOrders.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No orders currently on hold.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: heldOrders.length,
                separatorBuilder: (_, _) => const Divider(color: AppColors.border),
                itemBuilder: (ctx, index) {
                  final held = heldOrders[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(Icons.pause_circle_outline, color: AppColors.primary),
                    ),
                    title: Text(held.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    subtitle: Text('Customer: ${held.customerName ?? "Walk-in"} • ${held.heldAt.hour}:${held.heldAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        onResumeOrder(held);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Resume', style: TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}
