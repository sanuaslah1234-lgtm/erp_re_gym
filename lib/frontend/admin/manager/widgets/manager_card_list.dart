import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../../branch/widgets/status_badge.dart';
import 'package:erp_software/core/models/manager_model.dart';
import 'manager_actions_menu.dart';

class ManagerCardList extends StatelessWidget {
  final List<ManagerModel> managers;

  const ManagerCardList({super.key, required this.managers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: managers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final m = managers[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text(m.employeeId,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  StatusBadge(isActive: m.isVerified),
                  ManagerActionsMenu(manager: m),
                ],
              ),
              const Divider(height: 20, color: AppColors.border),
              Row(children: [
                const Icon(Icons.apartment_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  m.branchName != null ? '${m.branchCode} — ${m.branchName}' : 'Unassigned',
                  style: TextStyle(
                    fontSize: 13,
                    color: m.branchName != null ? AppColors.textPrimary : AppColors.textMuted,
                    fontStyle: m.branchName != null ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(child: Text(m.email, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(m.phone, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ]),
            ],
          ),
        );
      },
    );
  }
}
