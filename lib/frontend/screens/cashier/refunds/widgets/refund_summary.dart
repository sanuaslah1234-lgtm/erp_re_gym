import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

class RefundSummaryWidget extends StatelessWidget {
  final double calculatedTotal;
  final String refundMethod;
  final String reason;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onSubmitRefund;
  final bool isLoading;

  const RefundSummaryWidget({
    super.key,
    required this.calculatedTotal,
    required this.refundMethod,
    required this.reason,
    required this.onMethodChanged,
    required this.onReasonChanged,
    required this.onSubmitRefund,
    required this.isLoading,
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
          const Text('Refund Confirmation Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Refund Amount:', style: TextStyle(color: AppColors.textSecondary)),
              Text('\$${calculatedTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: refundMethod,
            decoration: const InputDecoration(labelText: 'Refund Method'),
            items: const [
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              DropdownMenuItem(value: 'Card', child: Text('Card / Original Payment')),
              DropdownMenuItem(value: 'Store Credit', child: Text('Store Credit')),
            ],
            onChanged: (val) => onMethodChanged(val ?? 'Cash'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: reason,
            onChanged: onReasonChanged,
            decoration: const InputDecoration(labelText: 'Reason for Refund'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: calculatedTotal > 0 && !isLoading ? onSubmitRefund : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)) : const Icon(Icons.replay),
              label: const Text('Process Refund & Restore Stock', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
