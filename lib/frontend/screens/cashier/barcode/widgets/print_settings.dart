import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

class PrintSettingsWidget extends StatelessWidget {
  final int labelCount;
  final String paperSize;
  final ValueChanged<String> onPaperSizeChanged;

  const PrintSettingsWidget({
    super.key,
    required this.labelCount,
    required this.paperSize,
    required this.onPaperSizeChanged,
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
          const Text('Label Print Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Labels to Print:', style: TextStyle(color: AppColors.textSecondary)),
              Text('$labelCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: paperSize,
            decoration: const InputDecoration(labelText: 'Label Size / Roll'),
            items: const [
              DropdownMenuItem(value: '50mm x 30mm (Standard Roll)', child: Text('50mm x 30mm (Standard Roll)')),
              DropdownMenuItem(value: '40mm x 25mm (Compact)', child: Text('40mm x 25mm (Compact)')),
              DropdownMenuItem(value: 'A4 Sheet (24 Labels/Page)', child: Text('A4 Sheet (24 Labels/Page)')),
            ],
            onChanged: (val) => onPaperSizeChanged(val ?? paperSize),
          ),
        ],
      ),
    );
  }
}
