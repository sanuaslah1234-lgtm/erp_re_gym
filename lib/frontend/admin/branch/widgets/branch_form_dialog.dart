import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import 'package:erp_software/core/models/branch_model.dart';
import '../providers/branch_provider.dart';

class BranchFormDialog extends StatefulWidget {
  /// Pass null to create a new branch, pass a branch to edit it.
  final BranchModel? existingBranch;

  const BranchFormDialog({super.key, this.existingBranch});

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late bool _isActive;

  bool get _isEditing => widget.existingBranch != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBranch;
    _codeCtrl = TextEditingController(text: b?.code ?? '');
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _addressCtrl = TextEditingController(text: b?.address ?? '');
    _cityCtrl = TextEditingController(text: b?.city ?? '');
    _stateCtrl = TextEditingController(text: b?.state ?? '');
    _phoneCtrl = TextEditingController(text: b?.phone ?? '');
    _emailCtrl = TextEditingController(text: b?.email ?? '');
    _isActive = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BranchProvider>();
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
                    _isEditing ? 'Edit Branch' : 'Add New Branch',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  _row([
                    _field('Branch Code', _codeCtrl, validator: (v) => _required(v, 'Code')),
                    _field('Branch Name', _nameCtrl, validator: (v) => _required(v, 'Name')),
                  ]),
                  const SizedBox(height: 14),
                  _field('Address', _addressCtrl,
                      validator: (v) => _required(v, 'Address'), maxLines: 2),
                  const SizedBox(height: 14),
                  _row([
                    _field('City', _cityCtrl, validator: (v) => _required(v, 'City')),
                    _field('State', _stateCtrl, validator: (v) => _required(v, 'State')),
                  ]),
                  const SizedBox(height: 14),
                  _row([
                    _field('Phone', _phoneCtrl,
                        validator: (v) => _required(v, 'Phone'),
                        keyboardType: TextInputType.phone),
                    _field('Email', _emailCtrl,
                        validator: _validateEmail, keyboardType: TextInputType.emailAddress),
                  ]),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primary,
                    title: const Text('Active', style: TextStyle(color: AppColors.textPrimary)),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: provider.isMutating
                            ? null
                            : () => Navigator.of(context).pop(),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(_isEditing ? 'Save Changes' : 'Create Branch'),
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

  Widget _row(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 420;
      if (isNarrow) {
        return Column(
          children: [
            children[0],
            const SizedBox(height: 14),
            children[1],
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 14),
          Expanded(child: children[1]),
        ],
      );
    });
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Future<void> _submit(BranchProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final branch = BranchModel(
      id: widget.existingBranch?.id,
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      isActive: _isActive,
    );

    final success = _isEditing
        ? await provider.updateBranch(widget.existingBranch!.id!, branch)
        : await provider.createBranch(branch);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (_isEditing ? 'Branch updated successfully' : 'Branch created successfully')
              : provider.errorMessage ?? 'Something went wrong',
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }
}

