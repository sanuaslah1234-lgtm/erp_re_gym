import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/reports_provider.dart';

class CustomerFilterDropdown extends StatelessWidget {
  const CustomerFilterDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter by Customer', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: provider.customers.contains(provider.selectedCustomer)
                  ? provider.selectedCustomer
                  : 'All Customers',
              items: provider.customers
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: AppColors.textPrimary))))
                  .toList(),
              onChanged: (value) {
                if (value != null) provider.setCustomer(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
