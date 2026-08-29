import 'package:flutter/material.dart';
import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/employee_provider.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

class EditEmployeeScreen extends StatefulWidget {
  final EmployeeModel employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _empIdController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _designationController;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.employee.fullName);
    _empIdController = TextEditingController(text: widget.employee.employeeId);
    _emailController = TextEditingController(text: widget.employee.email);
    _phoneController = TextEditingController(text: widget.employee.phone);
    _departmentController = TextEditingController(text: widget.employee.branchId ?? '');
    _designationController = TextEditingController(text: widget.employee.type ?? '');
    _selectedRole = widget.employee.role;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _empIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

      final data = {
        'full_name': _fullNameController.text.trim(),
        'employee_id': _empIdController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'department': _departmentController.text.trim(),
        'designation': _designationController.text.trim(),
        'role': _selectedRole ?? 'employee',
        'is_verified': widget.employee.isVerified,
      };

      if (widget.employee.id != null) {
        final success = await employeeProvider.updateEmployee(
          authProvider.token,
          widget.employee.id!,
          data,
        );

        if (!mounted) return;

        if (success) {
          ErpToast.showSuccess(
            context,
            'Employee updated successfully!',
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final empProvider = Provider.of<EmployeeProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Employees'),

          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Employees', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Text('Edit', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Edit Employee - ${widget.employee.employeeId}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 12),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: empProvider.isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: empProvider.isLoading
                                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: EdgeInsets.all(isMobile ? 20.0 : 28.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Employee Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                const SizedBox(height: 20),

                                _buildResponsiveRow(
                                  isMobile,
                                  _buildInputField(label: 'Full Name *', controller: _fullNameController),
                                  _buildInputField(label: 'Employee ID *', controller: _empIdController, isTinted: true),
                                ),
                                const SizedBox(height: 16),

                                _buildResponsiveRow(
                                  isMobile,
                                  _buildInputField(label: 'Email *', controller: _emailController),
                                  _buildInputField(label: 'Phone Number *', controller: _phoneController),
                                ),
                                const SizedBox(height: 16),

                                _buildResponsiveRow(
                                  isMobile,
                                  _buildDropdownField(
                                    label: 'Role *',
                                    value: _selectedRole,
                                    items: ['admin', 'manager', 'employee', 'HR'],
                                    onChanged: (val) => setState(() => _selectedRole = val),
                                  ),
                                  _buildInputField(label: 'Department', controller: _departmentController),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildResponsiveRow(bool isMobile, Widget left, Widget right) {
    if (isMobile) {
      return Column(
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isTinted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isTinted ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
