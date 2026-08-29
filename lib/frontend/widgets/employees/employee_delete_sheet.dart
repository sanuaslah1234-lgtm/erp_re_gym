import 'package:flutter/material.dart';

import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/theme/app_colors.dart';

class EmployeeDeleteSheet extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onDelete;

  const EmployeeDeleteSheet({
    super.key,
    required this.employee,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_remove_alt_1_rounded,
                size: 30,
                color: AppColors.danger,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Remove Employee?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'This employee will be removed from your employee list.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      employee.initials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          employee.displayEmployeeId,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        48,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                      side: const BorderSide(
                        color: AppColors.borderMedium,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: FilledButton(
                    onPressed: onDelete,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(
                        double.infinity,
                        48,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
