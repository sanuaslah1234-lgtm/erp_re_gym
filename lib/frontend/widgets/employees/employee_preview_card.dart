import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class EmployeePreviewCard
    extends StatelessWidget {
  final String name;
  final String? role;
  final String employeeId;

  const EmployeePreviewCard({
    super.key,
    required this.name,
    required this.role,
    required this.employeeId,
  });

  String get initials {
    final value = name.trim();

    if (value.isEmpty) {
      return '';
    }

    final parts =
        value.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first
          .substring(0, 1)
          .toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
        '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        name.trim().isEmpty
            ? 'New Employee'
            : name.trim();

    final displayRole =
        role == null || role!.isEmpty
            ? 'Role not set'
            : role!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: AppShadows.primary,
              ),
              alignment: Alignment.center,
              child: initials.isEmpty
                  ? const Icon(
                      Icons.person_outline_rounded,
                      size: 34,
                      color: AppColors.white,
                    )
                  : Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 15),

          Center(
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                displayRole,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Divider(
            color: AppColors.border,
            height: 1,
          ),

          const SizedBox(height: 15),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 17,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Employee ID',
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      employeeId.isEmpty
                          ? 'Not set'
                          : employeeId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding:
                const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color:
                  AppColors.surfaceSecondary,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is how the employee will appear in your team list once saved.',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
