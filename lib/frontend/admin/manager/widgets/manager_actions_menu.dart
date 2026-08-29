import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/manager_model.dart';
import '../providers/manager_provider.dart';
import 'manager_form_dialog.dart';

class ManagerActionsMenu extends StatelessWidget {
  final ManagerModel manager;

  const ManagerActionsMenu({super.key, required this.manager});

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
            builder: (_) => ManagerFormDialog(existingManager: manager),
          );
        } else if (value == 'delete') {
          _confirmDelete(context);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
            SizedBox(width: 10),
            Text('Delete', style: TextStyle(color: AppColors.danger)),
          ]),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    final provider = context.read<ManagerProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Manager', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${manager.fullName}" (${manager.employeeId})? '
          'This will remove their login access. This action cannot be undone.',
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
              final success = await provider.deleteManager(manager.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Manager deleted successfully'
                          : provider.errorMessage ?? 'Failed to delete manager',
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

