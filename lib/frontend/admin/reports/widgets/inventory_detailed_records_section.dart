import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/inventory_record_model.dart';
import '../providers/inventory_reports_provider.dart';

class InventoryDetailedRecordsSection extends StatelessWidget {
  const InventoryDetailedRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryReportsProvider>();
    final records = provider.records;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Inventory Records', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          if (provider.isLoading)
            const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
          else if (records.isEmpty)
            _emptyState()
          else ...[
            _table(records),
            const SizedBox(height: 12),
            Text('Showing ${records.length} item${records.length == 1 ? '' : 's'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted),
        SizedBox(height: 12),
        Text('No Items Found', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        SizedBox(height: 4),
        Text('Try a different category or search term.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ]),
    );
  }

  Widget _table(List<InventoryRecordModel> records) {
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
                SizedBox(width: 90, child: Text('SKU', style: headerStyle)),
                Expanded(child: Text('ITEM NAME', style: headerStyle)),
                SizedBox(width: 110, child: Text('CATEGORY', style: headerStyle)),
                SizedBox(width: 80, child: Text('STOCK', style: headerStyle, textAlign: TextAlign.right)),
                SizedBox(width: 90, child: Text('REORDER', style: headerStyle, textAlign: TextAlign.right)),
                SizedBox(width: 90, child: Text('UNIT COST', style: headerStyle, textAlign: TextAlign.right)),
                SizedBox(width: 90, child: Text('TOTAL VALUE', style: headerStyle, textAlign: TextAlign.right)),
                SizedBox(width: 100, child: Text('STATUS', style: headerStyle)),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...records.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    SizedBox(width: 90, child: Text(r.sku, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    Expanded(child: Text(r.itemName, style: const TextStyle(color: AppColors.textPrimary))),
                    SizedBox(width: 110, child: Text(r.category.isNotEmpty ? r.category : '-', style: const TextStyle(color: AppColors.textSecondary))),
                    SizedBox(width: 80, child: Text('${r.quantityInStock}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    SizedBox(width: 90, child: Text('${r.reorderLevel}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textSecondary))),
                    SizedBox(width: 90, child: Text('\$${r.unitCost.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textSecondary))),
                    SizedBox(width: 90, child: Text('\$${r.totalValue.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    SizedBox(width: 100, child: _StockBadge(status: r.stockStatus)),
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final String status;
  const _StockBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    late String label;
    switch (status) {
      case 'out':
        color = AppColors.danger;
        label = 'Out of Stock';
        break;
      case 'low':
        color = AppColors.warning;
        label = 'Low Stock';
        break;
      default:
        color = AppColors.success;
        label = 'In Stock';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }
}
