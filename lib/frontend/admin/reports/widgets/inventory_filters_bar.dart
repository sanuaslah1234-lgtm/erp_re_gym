import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/inventory_reports_provider.dart';

class InventoryFiltersBar extends StatelessWidget {
  const InventoryFiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryReportsProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 700;

    final categoryDropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: provider.categories.contains(provider.selectedCategory) ? provider.selectedCategory : 'All Categories',
          items: provider.categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
          onChanged: (v) {
            if (v != null) provider.setCategory(v);
          },
        ),
      ),
    );

    final searchField = TextField(
      onChanged: provider.setRecordsSearch,
      decoration: InputDecoration(
        hintText: 'Search by SKU or item name...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.pageBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      ),
    );

    if (isNarrow) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [searchField, const SizedBox(height: 10), categoryDropdown]);
    }

    return Row(children: [
      Expanded(flex: 2, child: searchField),
      const SizedBox(width: 12),
      Expanded(child: categoryDropdown),
    ]);
  }
}
