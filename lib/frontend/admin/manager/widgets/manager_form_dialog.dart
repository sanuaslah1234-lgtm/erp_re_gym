import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/manager_model.dart';
import '../providers/manager_provider.dart';

class ManagerFormDialog extends StatefulWidget {
  final ManagerModel? existingManager;

  const ManagerFormDialog({super.key, this.existingManager});

  @override
  State<ManagerFormDialog> createState() => _ManagerFormDialogState();
}

class _ManagerFormDialogState extends State<ManagerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;
  int? _selectedBranchId;
  late bool _isVerified;

  bool get _isEditing => widget.existingManager != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existingManager;
    _nameCtrl = TextEditingController(text: m?.fullName ?? '');
    _emailCtrl = TextEditingController(text: m?.email ?? '');
    _phoneCtrl = TextEditingController(text: m?.phone ?? '');
    _passwordCtrl = TextEditingController();
    _selectedBranchId = m?.branchId;
    _isVerified = m?.isVerified ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _required(value, 'Email');
    if (requiredError != null) return requiredError;
    final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(value!.trim());
    return ok ? null : 'Enter a valid email';
  }

  String? _validatePassword(String? value) {
    final v = value?.trim() ?? '';
    if (_isEditing && v.isEmpty) return null; // optional on edit
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerProvider>();
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width < 600 ? width * 0.92 : 560.0;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Edit Manager' : 'Add New Manager',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 4),
                    Text('ID: ${widget.existingManager!.employeeId}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                  _field('Full Name', _nameCtrl, validator: (v) => _required(v, 'Full Name')),
                  const SizedBox(height: 14),
                  _row([
                    _field('Email', _emailCtrl,
                        validator: _validateEmail, keyboardType: TextInputType.emailAddress),
                    _field('Phone', _phoneCtrl,
                        validator: (v) => _required(v, 'Phone'), keyboardType: TextInputType.phone),
                  ]),
                  const SizedBox(height: 14),
                  _field(
                    _isEditing ? 'New Password (leave blank to keep current)' : 'Password',
                    _passwordCtrl,
                    validator: _validatePassword,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  _branchDropdown(provider),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primary,
                    title: const Text('Verified', style: TextStyle(color: AppColors.textPrimary)),
                    value: _isVerified,
                    onChanged: (v) => setState(() => _isVerified = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: provider.isMutating ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: provider.isMutating ? null : () => _submit(provider),
                        child: provider.isMutating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : Text(_isEditing ? 'Save Changes' : 'Create Manager'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _branchDropdown(ManagerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assign Branch', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              isExpanded: true,
              hint: const Text('No branch assigned', style: TextStyle(color: AppColors.textSecondary)),
              value: _selectedBranchId,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('No branch assigned', style: TextStyle(color: AppColors.textPrimary))),
                ...provider.branchOptions.map(
                  (b) => DropdownMenuItem<int?>(
                    value: b.id,
                    child: Text('${b.code} — ${b.name}', style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedBranchId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 420;
      if (isNarrow) {
        return Column(children: [children[0], const SizedBox(height: 14), children[1]]);
      }
      return Row(children: [
        Expanded(child: children[0]),
        const SizedBox(width: 14),
        Expanded(child: children[1]),
      ]);
    });
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Future<void> _submit(ManagerProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final manager = ManagerModel(
      id: widget.existingManager?.id,
      employeeId: widget.existingManager?.employeeId ?? '',
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      isVerified: _isVerified,
      branchId: _selectedBranchId,
    );

    final success = _isEditing
        ? await provider.updateManager(
            widget.existingManager!.id!,
            manager,
            password: _passwordCtrl.text.trim(),
          )
        : await provider.createManager(manager, _passwordCtrl.text.trim());

    if (!mounted) return;

    if (success) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (_isEditing ? 'Manager updated successfully' : 'Manager created successfully')
              : provider.errorMessage ?? 'Something went wrong',
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }
}

