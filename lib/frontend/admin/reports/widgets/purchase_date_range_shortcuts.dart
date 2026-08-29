import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/purchase_reports_provider.dart';
import '../providers/reports_provider.dart' show DateShortcut;

class PurchaseDateRangeShortcuts extends StatelessWidget {
  const PurchaseDateRangeShortcuts({super.key});

  String _label(DateShortcut s) {
    switch (s) {
      case DateShortcut.today:
        return 'Today';
      case DateShortcut.yesterday:
        return 'Yesterday';
      case DateShortcut.last7Days:
        return 'Last 7 Days';
      case DateShortcut.last30Days:
        return 'Last 30 Days';
      case DateShortcut.thisMonth:
        return 'This Month';
      case DateShortcut.custom:
        return 'Custom Range';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseReportsProvider>();

    final shortcuts = [
      DateShortcut.today,
      DateShortcut.yesterday,
      DateShortcut.last7Days,
      DateShortcut.last30Days,
      DateShortcut.thisMonth,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...shortcuts.map((s) => _Chip(
              label: _label(s),
              active: provider.activeShortcut == s,
              onTap: () => provider.applyShortcut(s),
            )),
        _Chip(label: 'Custom Range', active: provider.activeShortcut == DateShortcut.custom, onTap: () {}),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
