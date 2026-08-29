import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/purchase_reports_provider.dart';
import '../widgets/purchase_date_pickers_row.dart';
import '../widgets/purchase_date_range_shortcuts.dart';
import '../widgets/purchase_detailed_records_section.dart';
import '../widgets/purchase_summary_cards.dart';
import '../widgets/supplier_filter_dropdown.dart';

class PurchaseReportsView extends StatefulWidget {
  const PurchaseReportsView({super.key});

  @override
  State<PurchaseReportsView> createState() => _PurchaseReportsViewState();
}

class _PurchaseReportsViewState extends State<PurchaseReportsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseReportsProvider>().initIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseReportsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date Range Shortcut', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              SizedBox(height: 10),
              PurchaseDateRangeShortcuts(),
              SizedBox(height: 20),
              PurchaseDatePickersRow(),
              SizedBox(height: 20),
              SupplierFilterDropdown(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (provider.errorMessage != null && provider.summary.purchaseOrders == 0)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.danger.withValues(alpha: 0.3))),
            child: Row(children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.dangerText, fontSize: 13))),
              TextButton(onPressed: () => provider.fetchReport(), child: const Text('Retry')),
            ]),
          ),
        const PurchaseSummaryCards(),
        const SizedBox(height: 20),
        const PurchaseDetailedRecordsSection(),
      ],
    );
  }
}
