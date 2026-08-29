import 'package:flutter/material.dart';

import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/frontend/widgets/employees/employee_status.dart';
import 'package:erp_software/theme/app_colors.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              15,
              15,
              10,
              14,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _EmployeeAvatar(
                  initials:
                      employee.initials,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    AppColors
                                        .textPrimary,
                              ),
                            ),
                          ),

                          if (employee.verified)
                            const Padding(
                              padding:
                                  EdgeInsets.only(
                                left: 5,
                              ),
                              child: Icon(
                                Icons
                                    .verified_rounded,
                                size: 16,
                                color:
                                    AppColors
                                        .success,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        employee.displayRole,
                        style:
                            const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w700,
                          letterSpacing: .5,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color:
                        AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        onView();
                        break;

                      case 'edit':
                        onEdit();
                        break;

                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) {
                    return const [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .visibility_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('View'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .edit_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline_rounded,
                              size: 18,
                              color:
                                  AppColors
                                      .danger,
                            ),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          Container(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  AppColors.surfaceSecondary,
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon:
                      Icons.badge_outlined,
                  label: 'Employee ID',
                  value:
                      employee
                          .displayEmployeeId,
                ),

                const SizedBox(height: 9),

                _InfoRow(
                  icon:
                      Icons.email_outlined,
                  label: 'Email',
                  value:
                      employee.displayEmail,
                ),

                const SizedBox(height: 9),

                _InfoRow(
                  icon:
                      Icons.phone_outlined,
                  label: 'Phone',
                  value:
                      employee.displayPhone,
                ),

                const SizedBox(height: 9),

                _InfoRow(
                  icon:
                      Icons.business_outlined,
                  label: 'Branch',
                  value:
                      employee.displayBranch,
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              15,
              12,
              15,
              13,
            ),
            child: Row(
              children: [
                EmployeeStatus(
                  verified:
                      employee.verified,
                ),

                const Spacer(),

                _SmallAction(
                  icon:
                      Icons.visibility_outlined,
                  onTap: onView,
                ),

                const SizedBox(width: 7),

                _SmallAction(
                  icon:
                      Icons.edit_outlined,
                  onTap: onEdit,
                ),

                const SizedBox(width: 7),

                _SmallAction(
                  icon: Icons
                      .delete_outline_rounded,
                  danger: true,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// AVATAR
// ======================================================

class _EmployeeAvatar
    extends StatelessWidget {
  final String initials;

  const _EmployeeAvatar({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 53,
      height: 53,
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
        borderRadius:
            BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 15,
          fontWeight:
              FontWeight.w900,
          color: AppColors.white,
        ),
      ),
    );
  }
}

// ======================================================
// INFO ROW
// ======================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration:
              BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 15,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          label,
          style:
              const TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.w600,
            color:
                AppColors.textMuted,
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// ACTION
// ======================================================

class _SmallAction
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _SmallAction({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: danger
          ? AppColors.dangerLight
          : AppColors.surface,
      borderRadius:
          BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(9),
        child: Container(
          width: 36,
          height: 36,
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(9),
            border: Border.all(
              color: danger
                  ? AppColors.dangerLight
                  : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: danger
                ? AppColors.danger
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
