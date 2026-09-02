import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';

import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/frontend/services/employee_service.dart';

import 'package:erp_software/frontend/screens/employees/create_employee_screen.dart';

import 'package:erp_software/frontend/widgets/employees/employee_card.dart';
import 'package:erp_software/frontend/widgets/employees/employee_delete_sheet.dart';
import 'package:erp_software/frontend/widgets/employees/employee_details_sheet.dart';
import 'package:erp_software/frontend/widgets/employees/employee_filter_bar.dart';

import 'package:erp_software/theme/app_colors.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({
    super.key,
  });

  @override
  State<EmployeesScreen> createState() =>
      _EmployeesScreenState();
}

class _EmployeesScreenState
    extends State<EmployeesScreen> {
  late final EmployeeService employeeService;

  List<EmployeeModel> employees = [];

  String search = '';
  String roleFilter = 'All Roles';

  bool isLoading = true;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

    employeeService = EmployeeService();

    _loadEmployees();
  }

  // ==================================================
  // LOAD EMPLOYEES
  // ==================================================

  Future<void> _loadEmployees() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result =
          await employeeService.getEmployees();

      if (!mounted) return;

      setState(() {
        employees = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        _cleanError(e),
        error: true,
      );
    }
  }

  // ==================================================
  // FILTER
  // ==================================================

  List<EmployeeModel> get filteredEmployees {
    final query =
        search.trim().toLowerCase();

    return employees.where((employee) {
      final matchesSearch =
          query.isEmpty ||
          employee.name
              .toLowerCase()
              .contains(query) ||
          employee.displayEmail
              .toLowerCase()
              .contains(query) ||
          employee.displayEmployeeId
              .toLowerCase()
              .contains(query) ||
          employee.displayPhone
              .toLowerCase()
              .contains(query);

      final matchesRole =
          roleFilter == 'All Roles' ||
          employee.displayRole
              .toUpperCase() ==
              roleFilter.toUpperCase();

      return matchesSearch && matchesRole;
    }).toList();
  }

  // ==================================================
  // CREATE
  // ==================================================

  Future<void> _addEmployee() async {
    final created =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CreateEmployeeScreen(),
      ),
    );

    if (created == true) {
      await _loadEmployees();
    }
  }

  // ==================================================
  // VIEW
  // ==================================================

  void _showEmployeeDetails(
    EmployeeModel employee,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return EmployeeDetailsSheet(
          employee: employee,
        );
      },
    );
  }

  // ==================================================
  // EDIT
  // ==================================================

  Future<void> _editEmployee(
    EmployeeModel employee,
  ) async {
    // We will connect EditEmployeeScreen here.
    //
    // Example:
    //
    // final updated = await Navigator.push<bool>(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => EditEmployeeScreen(
    //       employee: employee,
    //     ),
    //   ),
    // );
    //
    // if (updated == true) {
    //   await _loadEmployees();
    // }

    _showMessage(
      'Edit screen will be connected next.',
    );
  }

  // ==================================================
  // DELETE CONFIRMATION
  // ==================================================

  void _confirmDelete(
    EmployeeModel employee,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return EmployeeDeleteSheet(
          employee: employee,
          onDelete: () async {
            Navigator.pop(context);

            await _deleteEmployee(
              employee,
            );
          },
        );
      },
    );
  }

  // ==================================================
  // DELETE
  // ==================================================

  Future<void> _deleteEmployee(
    EmployeeModel employee,
  ) async {
    final id = employee.id;

    if (id == null || id.isEmpty) {
      _showMessage(
        'Employee ID is missing',
        error: true,
      );
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      await employeeService.deleteEmployee(id);

      if (!mounted) return;

      setState(() {
        employees.removeWhere(
          (item) => item.id == id,
        );

        isDeleting = false;
      });

      _showMessage(
        '${employee.name} removed successfully',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      _showMessage(
        _cleanError(e),
        error: true,
      );
    }
  }

  // ==================================================
  // MESSAGE
  // ==================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            error
                ? AppColors.danger
                : AppColors.success,
      ),
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final visibleEmployees = filteredEmployees;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Employees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      EmployeeFilterBar(
                        search: search,
                        selectedRole: roleFilter,
                        employeeCount: visibleEmployees.length,
                        onSearchChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                        onRoleChanged: (value) {
                          setState(() {
                            roleFilter = value;
                          });
                        },
                        onAdd: _addEmployee,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadEmployees,
                          child: _buildBody(visibleEmployees),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    List<EmployeeModel> visibleEmployees,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (visibleEmployees.isEmpty) {
      return const _EmptyEmployees();
    }

    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior
              .onDrag,
      padding:
          const EdgeInsets.fromLTRB(
        14,
        2,
        14,
        30,
      ),
      itemCount:
          visibleEmployees.length,
      itemBuilder: (
        context,
        index,
      ) {
        final employee =
            visibleEmployees[index];

        return EmployeeCard(
          employee: employee,
          onView: () {
            _showEmployeeDetails(
              employee,
            );
          },
          onEdit: () {
            _editEmployee(
              employee,
            );
          },
          onDelete: () {
            if (!isDeleting) {
              _confirmDelete(
                employee,
              );
            }
          },
        );
      },
    );
  }
}

// ======================================================
// EMPTY
// ======================================================

class _EmptyEmployees
    extends StatelessWidget {
  const _EmptyEmployees();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  .5,
          child: Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primarySoft,
                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .people_outline_rounded,
                    size: 32,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'No employees found',
                  style:
                      TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                const Text(
                  'Try changing your search or filter.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
