import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/purchase_record_model.dart';
import '../providers/purchase_reports_provider.dart';

class PurchaseDetailedRecordsSection extends StatelessWidget {
  const PurchaseDetailedRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseReportsProvider>();
    final records = provider.records;
    final isNarrow = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isNarrow
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('Detailed Records', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _searchBox(provider),
                ])
              : Row(children: [
                  const Text('Detailed Records', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Spacer(),
                  SizedBox(width: 220, child: _searchBox(provider)),
                ]),
          const SizedBox(height: 20),
          if (provider.isLoading)
            const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
          else if (records.isEmpty)
            _emptyState()
          else ...[
            _table(records),
            const SizedBox(height: 12),
            Text('Showing ${records.length} record${records.length == 1 ? '' : 's'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _searchBox(PurchaseReportsProvider provider) {
    return TextField(
      onChanged: provider.setRecordsSearch,
      decoration: InputDecoration(
        hintText: 'Search records...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
        isDense: true,
        filled: true,
        fillColor: AppColors.pageBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.grid_view_rounded, size: 40, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No Records Found', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('Try modifying your filters or search keywords to display results.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _table(List<PurchaseRecordModel> records) {
    const headerStyle = TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 12);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                SizedBox(width: 100, child: Text('PURCHASE #', style: headerStyle)),
                Expanded(child: Text('SUPPLIER', style: headerStyle)),
                SizedBox(width: 90, child: Text('SUBTOTAL', style: headerStyle, textAlign: TextAlign.right)),
                SizedBox(width: 80, child: Text('TAX', style: headerStyle, textAlign: TextAlign.right)),
                SizedBox(width: 90, child: Text('TOTAL', style: headerStyle, textAlign: TextAlign.right)),
                SizedBox(width: 100, child: Text('STATUS', style: headerStyle)),
                SizedBox(width: 100, child: Text('DATE', style: headerStyle)),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...records.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    SizedBox(width: 100, child: Text(r.poNumber, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    Expanded(child: Text(r.supplierName, style: const TextStyle(color: AppColors.textPrimary))),
                    SizedBox(width: 90, child: Text('\$${r.subtotal.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textPrimary))),
                    SizedBox(width: 80, child: Text('\$${r.tax.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textSecondary))),
                    SizedBox(width: 90, child: Text('\$${r.total.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    SizedBox(width: 100, child: _StatusPill(status: r.status)),
                    SizedBox(
                      width: 100,
                      child: Text(
                        r.createdAt != null
                            ? '${r.createdAt!.day.toString().padLeft(2, '0')}-${r.createdAt!.month.toString().padLeft(2, '0')}-${r.createdAt!.year}'
                            : '-',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'completed': color = AppColors.success; break;
      case 'pending': color = AppColors.warning; break;
      case 'cancelled': color = AppColors.danger; break;
      default: color = AppColors.neutral;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
