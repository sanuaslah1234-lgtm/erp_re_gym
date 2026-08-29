import 'package:flutter/material.dart';

import 'employee_dropdown_field.dart';
import 'employee_form_field.dart';
import 'package:erp_software/theme/app_colors.dart';

class EmployeeFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController employeeIdController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  final String? selectedRole;
  final String? selectedBranch;

  final bool obscurePassword;

  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onBranchChanged;

  final VoidCallback onPasswordVisibilityChanged;

  const EmployeeFormCard({
    super.key,
    required this.nameController,
    required this.employeeIdController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.selectedRole,
    required this.selectedBranch,
    required this.obscurePassword,
    required this.onRoleChanged,
    required this.onBranchChanged,
    required this.onPasswordVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Information',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Enter employee account details',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns =
                  constraints.maxWidth >= 650;

              if (twoColumns) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: EmployeeFormField(
                            controller:
                                nameController,
                            label: 'Full Name',
                            hint: 'John Doe',
                            prefixIcon:
                                Icons.person_outline,
                            required: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter full name';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: EmployeeFormField(
                            controller:
                                employeeIdController,
                            label: 'Employee ID',
                            hint: 'EMP-001',
                            prefixIcon:
                                Icons.badge_outlined,
                            required: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter employee ID';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: EmployeeFormField(
                            controller:
                                emailController,
                            label: 'Email',
                            hint:
                                'john@example.com',
                            prefixIcon:
                                Icons.email_outlined,
                            keyboardType:
                                TextInputType
                                    .emailAddress,
                            required: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter email';
                              }

                              if (!value.contains('@')) {
                                return 'Enter valid email';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: EmployeeFormField(
                            controller:
                                phoneController,
                            label: 'Phone Number',
                            hint: '9876543210',
                            prefixIcon:
                                Icons.phone_outlined,
                            keyboardType:
                                TextInputType.phone,
                            required: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter phone number';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child:
                              EmployeeDropdownField(
                            label: 'Role',
                            hint: 'Select Role',
                            value: selectedRole,
                            icon:
                                Icons.admin_panel_settings_outlined,
                            required: true,
                            items: const [
                              'ADMIN',
                              'SUPER_ADMIN',
                              'MANAGER',
                              'STAFF',
                            ],
                            onChanged:
                                onRoleChanged,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child:
                              EmployeeDropdownField(
                            label: 'Branch',
                            hint: 'Select Branch',
                            value: selectedBranch,
                            icon:
                                Icons.business_outlined,
                            required: true,
                            items: const [
                              'Main Branch',
                              'Retail Branch',
                              'Gym Branch',
                            ],
                            onChanged:
                                onBranchChanged,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    EmployeeFormField(
                      controller:
                          passwordController,
                      label: 'Temporary Password',
                      hint:
                          'Enter temporary password',
                      prefixIcon:
                          Icons.lock_outline_rounded,
                      obscureText:
                          obscurePassword,
                      suffixIcon: IconButton(
                        onPressed:
                            onPasswordVisibilityChanged,
                        icon: Icon(
                          obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                          size: 19,
                        ),
                      ),
                      required: true,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Enter password';
                        }

                        if (value.length < 6) {
                          return 'Minimum 6 characters';
                        }

                        return null;
                      },
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  EmployeeFormField(
                    controller: nameController,
                    label: 'Full Name',
                    hint: 'John Doe',
                    prefixIcon:
                        Icons.person_outline,
                    required: true,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter full name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  EmployeeFormField(
                    controller:
                        employeeIdController,
                    label: 'Employee ID',
                    hint: 'EMP-001',
                    prefixIcon:
                        Icons.badge_outlined,
                    required: true,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter employee ID';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  EmployeeFormField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'john@example.com',
                    prefixIcon:
                        Icons.email_outlined,
                    keyboardType:
                        TextInputType.emailAddress,
                    required: true,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter email';
                      }

                      if (!value.contains('@')) {
                        return 'Enter valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  EmployeeFormField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hint: '9876543210',
                    prefixIcon:
                        Icons.phone_outlined,
                    keyboardType:
                        TextInputType.phone,
                    required: true,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter phone number';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  EmployeeDropdownField(
                    label: 'Role',
                    hint: 'Select Role',
                    value: selectedRole,
                    icon: Icons
                        .admin_panel_settings_outlined,
                    required: true,
                    items: const [
                      'ADMIN',
                      'SUPER_ADMIN',
                      'MANAGER',
                      'STAFF',
                    ],
                    onChanged: onRoleChanged,
                  ),

                  const SizedBox(height: 16),

                  EmployeeDropdownField(
                    label: 'Branch',
                    hint: 'Select Branch',
                    value: selectedBranch,
                    icon:
                        Icons.business_outlined,
                    required: true,
                    items: const [
                      'Main Branch',
                      'Retail Branch',
                      'Gym Branch',
                    ],
                    onChanged: onBranchChanged,
                  ),

                  const SizedBox(height: 16),

                  EmployeeFormField(
                    controller:
                        passwordController,
                    label: 'Temporary Password',
                    hint:
                        'Enter temporary password',
                    prefixIcon:
                        Icons.lock_outline_rounded,
                    obscureText:
                        obscurePassword,
                    suffixIcon: IconButton(
                      onPressed:
                          onPasswordVisibilityChanged,
                      icon: Icon(
                        obscurePassword
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                        size: 19,
                      ),
                    ),
                    required: true,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Enter password';
                      }

                      if (value.length < 6) {
                        return 'Minimum 6 characters';
                      }

                      return null;
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
