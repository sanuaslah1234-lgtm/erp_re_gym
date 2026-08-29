import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:erp_software/frontend/providers/employee_provider.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:provider/provider.dart';

import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _empIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  String? _selectedBranch;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onFormStateChanged);
    _empIdController.addListener(_onFormStateChanged);
    _emailController.addListener(_onFormStateChanged);
    _phoneController.addListener(_onFormStateChanged);
  }

  void _onFormStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFormStateChanged);
    _empIdController.removeListener(_onFormStateChanged);
    _emailController.removeListener(_onFormStateChanged);
    _phoneController.removeListener(_onFormStateChanged);

    _fullNameController.dispose();
    _empIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
        'role': _selectedRole ?? 'employee',
        'department': _selectedBranch ?? 'Main Branch',
        'password': _passwordController.text,
        'is_verified': true,
      };

      final success = await employeeProvider.addEmployee(authProvider.token, data);

      if (!mounted) return;

      if (success) {
        ErpToast.showSuccess(
          context,
          'Employee added successfully to PostgreSQL database!',
        );
        Navigator.pop(context);
      } else if (employeeProvider.errorMessage != null) {
        ErpToast.showError(
          context,
          employeeProvider.errorMessage!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final empProvider = Provider.of<EmployeeProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final previewName = _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : 'New Employee';
    final previewId = _empIdController.text.trim().isNotEmpty ? _empIdController.text.trim() : 'EMP001';
    final previewRole = _selectedRole != null ? 'Role: $_selectedRole' : 'Role not set';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          // Sidebar Panel for Desktop
          if (!isMobile) const ErpSidebar(activeItem: 'Employees'),

          // Main Screen Content Area
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
                        // Dynamic Breadcrumbs
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text('Employees', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Text('Add New', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title Bar & Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Add Employee',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                                if (!isMobile) ...[
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: empProvider.isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: empProvider.isLoading
                                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Text('Save Employee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Responsive Grid: 2-Column Desktop / Single Column Mobile
                        if (isMobile) ...[
                          _buildFormCard(isMobile),
                          const SizedBox(height: 20),
                          _buildPreviewCard(previewName, previewRole, previewId),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildFormCard(isMobile)),
                              const SizedBox(width: 24),
                              Expanded(flex: 1, child: _buildPreviewCard(previewName, previewRole, previewId)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: ElevatedButton(
                  onPressed: empProvider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: empProvider.isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Employee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFormCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20.0 : 28.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employee Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 20),

            _buildResponsiveRow(
              isMobile,
              _buildInputField(
                label: 'Full name *',
                controller: _fullNameController,
                hint: 'Full name',
                validator: (val) => val == null || val.trim().isEmpty ? 'Full name is required' : null,
              ),
              _buildInputField(
                label: 'EmployeeID *',
                controller: _empIdController,
                hint: 'EmployeeID',
                validator: (val) => val == null || val.trim().isEmpty ? 'EmployeeID is required' : null,
              ),
            ),
            const SizedBox(height: 16),

            _buildResponsiveRow(
              isMobile,
              _buildInputField(
                label: 'Email *',
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
              ),
              _buildInputField(
                label: 'Phonenumber *',
                controller: _phoneController,
                hint: 'Phonenumber',
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'Phonenumber is required' : null,
              ),
            ),
            const SizedBox(height: 16),

            _buildResponsiveRow(
              isMobile,
              _buildDropdownField(
                label: 'Role *',
                value: _selectedRole,
                hint: 'Select Role',
                items: ['admin', 'manager', 'employee', 'HR'],
                onChanged: (val) => setState(() => _selectedRole = val),
              ),
              _buildDropdownField(
                label: 'Branch *',
                value: _selectedBranch,
                hint: 'Select Branch',
                items: ['Main Branch', 'Executive', 'Engineering', 'Sales'],
                onChanged: (val) => setState(() => _selectedBranch = val),
              ),
            ),
            const SizedBox(height: 16),

            _buildInputField(
              label: 'Password *',
              controller: _passwordController,
              hint: 'Password',
              isPassword: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (val) => val == null || val.length < 4 ? 'Min 4 characters required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(String previewName, String previewRole, String previewId) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
                  child: const Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(
                  previewName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  previewRole,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    previewId,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Text(
                  'This is how the employee will appear in your team list once saved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
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
    String? hint,
    bool isPassword = false,
    bool isTinted = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
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
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
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
              value: value,
              hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
