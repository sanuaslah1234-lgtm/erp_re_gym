import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/reports_provider.dart';

class DatePickersRow extends StatelessWidget {
  const DatePickersRow({super.key});

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initial,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 700;

    final fromField = _DateField(
      label: 'From Date',
      value: _format(provider.fromDate),
      onTap: () => _pickDate(
        context: context,
        initial: provider.fromDate,
        onPicked: (d) => provider.setCustomDateRange(from: d),
      ),
    );

    final toField = _DateField(
      label: 'To Date',
      value: _format(provider.toDate),
      onTap: () => _pickDate(
        context: context,
        initial: provider.toDate,
        onPicked: (d) => provider.setCustomDateRange(to: d),
      ),
    );

    if (isNarrow) {
      return Column(
        children: [
          fromField,
          const SizedBox(height: 12),
          toField,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: fromField),
        const SizedBox(width: 16),
        Expanded(child: toField),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(color: AppColors.textPrimary)),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
