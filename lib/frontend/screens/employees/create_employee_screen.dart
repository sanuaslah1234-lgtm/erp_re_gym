import 'package:flutter/material.dart';

import 'package:erp_software/frontend/widgets/employees/employee_form_card.dart';
import 'package:erp_software/frontend/widgets/employees/employee_preview_card.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/services/employee_service.dart';
class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({
    super.key,
  });

  @override
  State<CreateEmployeeScreen> createState() =>
      _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState
    extends State<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController employeeIdController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  String? selectedRole;
  String? selectedBranch;

  bool obscurePassword = true;
  bool isSaving = false;

@override
void initState() {
  super.initState();

  nameController.addListener(_refreshPreview);
  employeeIdController.addListener(_refreshPreview);
}

void _refreshPreview() {
  if (mounted) {
    setState(() {});
  }
}

@override
void dispose() {
  nameController.removeListener(_refreshPreview);
  employeeIdController.removeListener(_refreshPreview);

  nameController.dispose();
  employeeIdController.dispose();
  emailController.dispose();
  phoneController.dispose();
  passwordController.dispose();

  super.dispose();
}

Future<void> _saveEmployee() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    isSaving = true;
  });

  try {
    final service = EmployeeService();

    await service.createEmployee(
      fullName:
          nameController.text.trim(),

      employeeId:
          employeeIdController.text
              .trim()
              .isEmpty
          ? null
          : employeeIdController.text
              .trim(),

      email:
          emailController.text.trim(),

      phone:
          phoneController.text.trim(),

      password:
          passwordController.text,

      role: selectedRole,

      branchId: selectedBranch,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Employee created successfully',
        ),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            AppColors.success,
      ),
    );

    Navigator.pop(
      context,
      true,
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst(
                'Exception: ',
                '',
              ),
        ),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            AppColors.danger,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile =
                  constraints.maxWidth < 800;

              if (isMobile) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    16,
                    14,
                    30,
                  ),
                  child: Column(
                    children: [
                      EmployeeFormCard(
                        nameController: nameController,
                        employeeIdController:
                            employeeIdController,
                        emailController:
                            emailController,
                        phoneController:
                            phoneController,
                        passwordController:
                            passwordController,
                        selectedRole: selectedRole,
                        selectedBranch: selectedBranch,
                        obscurePassword:
                            obscurePassword,
                        onRoleChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                        onBranchChanged: (value) {
                          setState(() {
                            selectedBranch = value;
                          });
                        },
                        onPasswordVisibilityChanged: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      EmployeePreviewCard(
                        name: nameController.text,
                        role: selectedRole,
                        employeeId:
                            employeeIdController.text,
                      ),

                      const SizedBox(height: 16),

                      _ActionButtons(
                        isSaving: isSaving,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onSave: _saveEmployee,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 1180,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: EmployeeFormCard(
                                nameController:
                                    nameController,
                                employeeIdController:
                                    employeeIdController,
                                emailController:
                                    emailController,
                                phoneController:
                                    phoneController,
                                passwordController:
                                    passwordController,
                                selectedRole:
                                    selectedRole,
                                selectedBranch:
                                    selectedBranch,
                                obscurePassword:
                                    obscurePassword,
                                onRoleChanged: (value) {
                                  setState(() {
                                    selectedRole =
                                        value;
                                  });
                                },
                                onBranchChanged:
                                    (value) {
                                  setState(() {
                                    selectedBranch =
                                        value;
                                  });
                                },
                                onPasswordVisibilityChanged:
                                    () {
                                  setState(() {
                                    obscurePassword =
                                        !obscurePassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              flex: 3,
                              child: EmployeePreviewCard(
                                name:
                                    nameController.text,
                                role: selectedRole,
                                employeeId:
                                    employeeIdController
                                        .text,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Align(
                          alignment:
                              Alignment.centerRight,
                          child: SizedBox(
                            width: 300,
                            child: _ActionButtons(
                              isSaving: isSaving,
                              onCancel: () {
                                Navigator.pop(
                                  context,
                                );
                              },
                              onSave: _saveEmployee,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ActionButtons({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                50,
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
          flex: 2,
          child: FilledButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 18,
                  ),
            label: Text(
              isSaving
                  ? 'Creating...'
                  : 'Create Employee',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              minimumSize: const Size(
                double.infinity,
                50,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(13),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
