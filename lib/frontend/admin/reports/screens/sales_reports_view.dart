import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/reports_provider.dart';
import '../widgets/customer_filter_dropdown.dart';
import '../widgets/date_pickers_row.dart';
import '../widgets/date_range_shortcuts.dart';
import '../widgets/detailed_records_section.dart';
import '../widgets/summary_cards.dart';

class SalesReportsView extends StatefulWidget {
  const SalesReportsView({super.key});

  @override
  State<SalesReportsView> createState() => _SalesReportsViewState();
}

class _SalesReportsViewState extends State<SalesReportsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filtersCard(),
        const SizedBox(height: 20),
        if (provider.errorMessage != null && provider.summary.salesOrders == 0) _errorBanner(provider),
        const SummaryCards(),
        const SizedBox(height: 20),
        const DetailedRecordsSection(),
      ],
    );
  }

  Widget _filtersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date Range Shortcut',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          SizedBox(height: 10),
          DateRangeShortcuts(),
          SizedBox(height: 20),
          DatePickersRow(),
          SizedBox(height: 20),
          CustomerFilterDropdown(),
        ],
      ),
    );
  }

  Widget _errorBanner(ReportsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(provider.errorMessage!,
                style: const TextStyle(color: AppColors.dangerText, fontSize: 13)),
          ),
          TextButton(onPressed: () => provider.fetchReport(), child: const Text('Retry')),
        ],
      ),
    );
  }
}
