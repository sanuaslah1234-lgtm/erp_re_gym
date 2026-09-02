import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddPaymentDialog extends StatefulWidget {
  final int? preselectedMemberId;
  final VoidCallback onSaved;

  const AddPaymentDialog({
    super.key,
    this.preselectedMemberId,
    required this.onSaved,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();

  int? _selectedMemberId;
  late TextEditingController _amountController;
  late TextEditingController _referenceController;
  late TextEditingController _notesController;

  String _paymentMethod = 'CASH';
  String _status = 'PAID';
  List<GymMemberModel> _members = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMemberId = widget.preselectedMemberId;
    _amountController = TextEditingController(text: '1500.00');
    _referenceController = TextEditingController(text: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _notesController = TextEditingController();
    _loadMembers();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await gymService.getMembers();
      if (!mounted) return;
      setState(() {
        _members = members;
        _isInitLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ErpToast.showError(context, 'Please select a member');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payment = GymPaymentModel(
        memberId: _selectedMemberId!,
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
        paymentMethod: _paymentMethod,
        paymentDate: DateTime.now(),
        referenceNumber: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
        status: _status,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await gymService.createPayment(payment);

      if (!mounted) return;
      ErpToast.showSuccess(context, 'Payment recorded successfully', title: 'Payment Saved');
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
    final memberItems = _members.map((m) => DropdownMenuItem<int>(
      value: m.id,
      child: Text('${m.name} (${m.memberCode})', maxLines: 1, overflow: TextOverflow.ellipsis),
    )).toList();

    if (_selectedMemberId != null && !memberItems.any((item) => item.value == _selectedMemberId)) {
      memberItems.insert(0, DropdownMenuItem<int>(
        value: _selectedMemberId!,
        child: Text('Member #$_selectedMemberId'),
      ));
    }

    final safeMemberValue = (_selectedMemberId != null && memberItems.any((item) => item.value == _selectedMemberId))
        ? _selectedMemberId
        : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth - 40).clamp(320.0, 500.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add_card_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Record Gym Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Collect membership dues, registration or service fees', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            _isInitLoading
                ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: safeMemberValue,
                            isExpanded: true,
                            decoration: _inputDecoration('Select Member *', icon: Icons.person_outline),
                            items: memberItems,
                            onChanged: (v) => setState(() => _selectedMemberId = v),
                            validator: (v) => v == null ? 'Please select a member' : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _amountController,
                            decoration: _inputDecoration('Amount *', icon: Icons.attach_money),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0) ? 'Enter valid amount' : null,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _paymentMethod,
                            isExpanded: true,
                            decoration: _inputDecoration('Payment Method', icon: Icons.account_balance_wallet_outlined),
                            items: const [
                              DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                              DropdownMenuItem(value: 'CARD', child: Text('Card')),
                              DropdownMenuItem(value: 'UPI', child: Text('UPI / QR')),
                              DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                              DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                            ],
                            onChanged: (v) => setState(() => _paymentMethod = v ?? 'CASH'),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _referenceController,
                            decoration: _inputDecoration('Transaction #', icon: Icons.tag),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _status,
                            isExpanded: true,
                            decoration: _inputDecoration('Payment Status', icon: Icons.toggle_on_outlined),
                            items: const [
                              DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                              DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                              DropdownMenuItem(value: 'PARTIAL', child: Text('Partial')),
                            ],
                            onChanged: (v) => setState(() => _status = v ?? 'PAID'),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: _inputDecoration('Payment Notes / Comments', icon: Icons.notes_outlined),
                          ),
                        ],
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _save,
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold)),
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

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF2563EB)) : null,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }
}
