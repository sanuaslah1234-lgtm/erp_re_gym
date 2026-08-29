import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/branch_model.dart';
import '../providers/branch_provider.dart';
import 'branch_form_dialog.dart';

class BranchActionsMenu extends StatelessWidget {
  final BranchModel branch;

  const BranchActionsMenu({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'edit') {
          showDialog(
            context: context,
            builder: (_) => BranchFormDialog(existingBranch: branch),
          );
        } else if (value == 'delete') {
          _confirmDelete(context);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: AppColors.danger)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    final provider = context.read<BranchProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Branch', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${branch.name}" (${branch.code})? '
          'This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.white),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await provider.deleteBranch(branch.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Branch deleted successfully'
                          : provider.errorMessage ?? 'Failed to delete branch',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

