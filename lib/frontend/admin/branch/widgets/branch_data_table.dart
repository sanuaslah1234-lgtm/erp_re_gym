import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/branch_model.dart';
import 'branch_actions_menu.dart';
import 'status_badge.dart';

class BranchDataTable extends StatelessWidget {
  final List<BranchModel> branches;

  const BranchDataTable({super.key, required this.branches});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      fontSize: 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 70, child: Text('Code', style: headerStyle)),
              Expanded(flex: 3, child: Text('Branch Name', style: headerStyle)),
              Expanded(flex: 3, child: Text('City & State', style: headerStyle)),
              Expanded(flex: 3, child: Text('Contact', style: headerStyle)),
              SizedBox(width: 90, child: Text('Status', style: headerStyle)),
              SizedBox(width: 60, child: Text('')),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: branches.length,
          separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
          itemBuilder: (context, index) {
            final b = branches[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      b.code,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                b.address,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('${b.city}, ${b.state}', style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(b.phone, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                b.email,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 90, child: StatusBadge(isActive: b.isActive)),
                  SizedBox(width: 60, child: BranchActionsMenu(branch: b)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
