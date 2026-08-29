import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../../branch/widgets/status_badge.dart';
import 'package:erp_software/core/models/manager_model.dart';
import 'manager_actions_menu.dart';

class ManagerDataTable extends StatelessWidget {
  final List<ManagerModel> managers;

  const ManagerDataTable({super.key, required this.managers});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            SizedBox(width: 70, child: Text('ID', style: headerStyle)),
            Expanded(flex: 3, child: Text('Manager', style: headerStyle)),
            Expanded(flex: 2, child: Text('Branch', style: headerStyle)),
            Expanded(flex: 3, child: Text('Contact', style: headerStyle)),
            SizedBox(width: 90, child: Text('Status', style: headerStyle)),
            SizedBox(width: 60, child: Text('')),
          ]),
        ),
        const Divider(height: 1, color: AppColors.border),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: managers.length,
          separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
          itemBuilder: (context, index) {
            final m = managers[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(m.employeeId,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(m.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      m.branchName != null ? '${m.branchCode} — ${m.branchName}' : 'Unassigned',
                      style: TextStyle(
                        color: m.branchName != null ? AppColors.textPrimary : AppColors.textMuted,
                        fontStyle: m.branchName != null ? FontStyle.normal : FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.email, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text(m.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  SizedBox(width: 90, child: StatusBadge(isActive: m.isVerified)),
                  SizedBox(width: 60, child: ManagerActionsMenu(manager: m)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
