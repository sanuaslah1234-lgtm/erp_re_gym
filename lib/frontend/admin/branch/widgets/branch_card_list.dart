import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/branch_model.dart';
import 'branch_actions_menu.dart';
import 'status_badge.dart';

class BranchCardList extends StatelessWidget {
  final List<BranchModel> branches;

  const BranchCardList({super.key, required this.branches});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: branches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = branches[index];
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.code,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(isActive: b.isActive),
                  BranchActionsMenu(branch: b),
                ],
              ),
              const SizedBox(height: 8),
              Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${b.address} · ${b.city}, ${b.state}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(b.phone, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(b.email,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
