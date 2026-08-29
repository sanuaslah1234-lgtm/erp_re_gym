import 'package:flutter/material.dart';

import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/theme/app_colors.dart';

class EmployeeDetailsSheet
    extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeDetailsSheet({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          24,
        ),
        decoration:
            const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.borderMedium,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                  ),
                  alignment:
                      Alignment.center,
                  child: Text(
                    employee.initials,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          AppColors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        employee.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w900,
                          color:
                              AppColors
                                  .textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        employee
                            .displayRole,
                        style:
                            const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                if (employee.verified)
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .successLight,
                      borderRadius:
                          BorderRadius.circular(
                        9,
                      ),
                    ),
                    child:
                        const Text(
                      'Verified',
                      style:
                          TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors
                                .successText,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'EMPLOYEE INFORMATION',
              style:
                  TextStyle(
                fontSize: 10,
                letterSpacing: 1,
                fontWeight:
                    FontWeight.w900,
                color:
                    AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 12),

            _DetailItem(
              icon:
                  Icons.badge_outlined,
              title: 'Employee ID',
              value:
                  employee
                      .displayEmployeeId,
            ),

            _DetailItem(
              icon:
                  Icons.email_outlined,
              title: 'Email',
              value:
                  employee.displayEmail,
            ),

            _DetailItem(
              icon:
                  Icons.phone_outlined,
              title: 'Phone',
              value:
                  employee.displayPhone,
            ),

            _DetailItem(
              icon:
                  Icons.business_outlined,
              title: 'Branch',
              value:
                  employee.displayBranch,
            ),

            _DetailItem(
              icon:
                  Icons.admin_panel_settings_outlined,
              title: 'Role',
              value:
                  employee.displayRole,
            ),

            _DetailItem(
              icon:
                  Icons.login_outlined,
              title: 'First Login',
              value:
                  employee.firstLogin
                      ? 'Yes'
                      : 'No',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.all(11),
      decoration:
          BoxDecoration(
        color:
            AppColors.surfaceSecondary,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,
              borderRadius:
                  BorderRadius.circular(9),
              border: Border.all(
                color:
                    AppColors.border,
              ),
            ),
            child: Icon(
              icon,
              size: 17,
              color:
                  AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors
                            .textPrimary,
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
