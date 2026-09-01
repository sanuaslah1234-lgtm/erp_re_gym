import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddEditPlanDialog extends StatefulWidget {
  final GymPlanModel? plan;
  final VoidCallback onSaved;

  const AddEditPlanDialog({super.key, this.plan, required this.onSaved});

  @override
  State<AddEditPlanDialog> createState() => _AddEditPlanDialogState();
}

class _AddEditPlanDialogState extends State<AddEditPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _taxController;

  String _status = 'ACTIVE';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _durationController = TextEditingController(text: (p?.durationDays ?? 30).toString());
    _priceController = TextEditingController(text: (p?.price ?? 1500.0).toStringAsFixed(2));
    _discountController = TextEditingController(text: (p?.discount ?? 0.0).toStringAsFixed(2));
    _taxController = TextEditingController(text: (p?.tax ?? 0.0).toStringAsFixed(2));
    if (p != null) _status = p.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  double get _calculatedTotal {
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0.0;
    final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
    return (price - discount + tax).clamp(0.0, 9999999.0);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final plan = GymPlanModel(
        id: widget.plan?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        durationDays: int.tryParse(_durationController.text.trim()) ?? 30,
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        discount: double.tryParse(_discountController.text.trim()) ?? 0.0,
        tax: double.tryParse(_taxController.text.trim()) ?? 0.0,
        totalAmount: _calculatedTotal,
        status: _status,
      );

      if (widget.plan == null) {
        await gymService.createPlan(plan);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Plan "${plan.name}" created', title: 'Plan Added');
      } else {
        await gymService.updatePlan(widget.plan!.id!, plan);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Plan "${plan.name}" updated', title: 'Plan Updated');
      }

      widget.onSaved();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plan != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth - 40).clamp(320.0, 500.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(isEdit ? Icons.edit_note_rounded : Icons.add_card_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Plan' : 'New Plan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(isEdit ? 'Update pricing & duration' : 'Configure duration, pricing & discounts', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Plan Name
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Plan Name *', icon: Icons.badge_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: _inputDecoration('Description', icon: Icons.notes_outlined),
                      ),
                      const SizedBox(height: 12),

                      // Duration + Status
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: _inputDecoration('Duration (Days) *', icon: Icons.timer_outlined),
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || int.tryParse(v.trim()) == null || int.parse(v.trim()) <= 0) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: _inputDecoration('Status', icon: Icons.toggle_on_outlined),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                                DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                              ],
                              onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price - single column on mobile
                      _buildTextField('Base Price *', Icons.attach_money, _priceController),
                      const SizedBox(height: 12),
                      _buildTextField('Discount', Icons.discount_outlined, _discountController),
                      const SizedBox(height: 12),
                      _buildTextField('Tax', Icons.receipt_outlined, _taxController),
                      const SizedBox(height: 16),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF))),
                                Text('Price - Disc + Tax', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              ],
                            ),
                            Text('\$${_calculatedTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _save,
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check, size: 18),
                      label: Text(isEdit ? 'Save' : 'Create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon: icon),
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      prefixIcon: icon != null ? Icon(icon, size: 16, color: const Color(0xFF2563EB)) : null,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }
}
