import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class EmployeeFilterBar
    extends StatelessWidget {
  final String search;
  final String selectedRole;
  final int employeeCount;

  final ValueChanged<String>
      onSearchChanged;

  final ValueChanged<String>
      onRoleChanged;

  final VoidCallback onAdd;

  const EmployeeFilterBar({
    super.key,
    required this.search,
    required this.selectedRole,
    required this.employeeCount,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        12,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    border: Border.all(
                      color:
                          AppColors.border,
                    ),
                    boxShadow:
                        AppShadows.soft,
                  ),
                  child: TextField(
                    onChanged:
                        onSearchChanged,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Search employees',
                      prefixIcon:
                          Icon(
                        Icons
                            .search_rounded,
                        size: 21,
                        color: AppColors
                            .textSecondary,
                      ),
                      border:
                          InputBorder.none,
                      contentPadding:
                          EdgeInsets
                              .symmetric(
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Material(
                color:
                    AppColors.primary,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  onTap: onAdd,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons
                          .person_add_alt_1_rounded,
                      color:
                          AppColors.white,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primarySoft,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons
                          .groups_2_outlined,
                      size: 16,
                      color:
                          AppColors.primary,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      '$employeeCount Employees',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors
                                .primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Container(
                height: 38,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 4,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                  border: Border.all(
                    color:
                        AppColors.border,
                  ),
                ),
                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<
                          String>(
                    value:
                        selectedRole,
                    icon:
                        const Padding(
                      padding:
                          EdgeInsets.only(
                        right: 5,
                      ),
                      child:
                          Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppColors
                              .textPrimary,
                    ),
                    padding:
                        const EdgeInsets
                            .only(
                      left: 8,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value:
                            'All Roles',
                        child:
                            Text(
                          'All Roles',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'ADMIN',
                        child:
                            Text(
                          'Admin',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'SUPER_ADMIN',
                        child:
                            Text(
                          'Super Admin',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'MANAGER',
                        child:
                            Text(
                          'Manager',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'STAFF',
                        child:
                            Text(
                          'Staff',
                        ),
                      ),
                    ],
                    onChanged:
                        (value) {
                      if (value !=
                          null) {
                        onRoleChanged(
                          value,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
