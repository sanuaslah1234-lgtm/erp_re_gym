import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/branch_provider.dart';
import 'branch_form_dialog.dart';

class BranchToolbar extends StatelessWidget {
  const BranchToolbar({super.key});

  String _sortLabel(BranchSort s) {
    switch (s) {
      case BranchSort.defaultOrder:
        return 'Sort (default)';
      case BranchSort.nameAZ:
        return 'Name (A-Z)';
      case BranchSort.nameZA:
        return 'Name (Z-A)';
      case BranchSort.newest:
        return 'Newest';
      case BranchSort.oldest:
        return 'Oldest';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BranchProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 700;

    final searchField = TextField(
      onChanged: provider.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search branches...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.pageBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );

    final sortDropdown = DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<BranchSort>(
          value: provider.sortOption,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          items: BranchSort.values
              .map((s) => DropdownMenuItem(value: s, child: Text(_sortLabel(s), style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))))
              .toList(),
          onChanged: (value) {
            if (value != null) provider.setSort(value);
          },
        ),
      ),
    );

    final refreshButton = OutlinedButton(
      onPressed: provider.isLoading ? null : () => provider.fetchBranches(),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: provider.isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
    );

    final addButton = FilledButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => const BranchFormDialog(),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Branch'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: sortDropdown),
              const SizedBox(width: 10),
              refreshButton,
            ],
          ),
          const SizedBox(height: 10),
          addButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 12),
        sortDropdown,
        const SizedBox(width: 12),
        refreshButton,
        const SizedBox(width: 12),
        addButton,
      ],
    );
  }
}

