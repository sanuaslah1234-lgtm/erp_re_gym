import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class RenewMembershipDialog extends StatefulWidget {
  final GymMembershipModel membership;
  final VoidCallback onRenewed;

  const RenewMembershipDialog({super.key, required this.membership, required this.onRenewed});

  @override
  State<RenewMembershipDialog> createState() => _RenewMembershipDialogState();
}

class _RenewMembershipDialogState extends State<RenewMembershipDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();

  int? _selectedPlanId;
  late DateTime _startDate;
  late DateTime _endDate;
  String _paymentMethod = 'CASH';
  late TextEditingController _paidAmountController;

  List<GymPlanModel> _plans = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    final ms = widget.membership;
    _selectedPlanId = ms.planId;
    _startDate = ms.endDate.isAfter(DateTime.now()) ? ms.endDate.add(const Duration(days: 1)) : DateTime.now();
    _endDate = _startDate.add(const Duration(days: 30));
    _paidAmountController = TextEditingController(text: ms.finalAmount.toStringAsFixed(2));
    _loadPlans();
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await gymService.getPlans(status: 'ACTIVE');
      if (!mounted) return;
      setState(() {
        _plans = plans;
        if (_plans.isNotEmpty) {
          final p = _plans.firstWhere((p) => p.id == _selectedPlanId, orElse: () => _plans.first);
          _selectedPlanId = p.id;
          _endDate = _startDate.add(Duration(days: p.durationDays));
          _paidAmountController.text = p.totalAmount.toStringAsFixed(2);
        }
        _isInitLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  void _onPlanChanged(int? planId) {
    setState(() {
      _selectedPlanId = planId;
      if (planId != null && _plans.isNotEmpty) {
        final p = _plans.firstWhere((p) => p.id == planId, orElse: () => _plans.first);
        _endDate = _startDate.add(Duration(days: p.durationDays));
        _paidAmountController.text = p.totalAmount.toStringAsFixed(2);
      }
    });
  }

  Future<void> _renew() async {
    if (_selectedPlanId == null) {
      ErpToast.showError(context, 'Please choose a plan');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paid = double.tryParse(_paidAmountController.text.trim());
      await gymService.renewMembership(
        widget.membership.id!,
        _selectedPlanId!,
        customStartDate: _startDate,
        paidAmount: paid,
        paymentMethod: _paymentMethod,
      );

      if (!mounted) return;
      ErpToast.showSuccess(context, 'Membership renewed!', title: 'Done');
      widget.onRenewed();
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
    final ms = widget.membership;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth - 40).clamp(320.0, 500.0);

    final planItems = _plans.map((p) => DropdownMenuItem<int>(
      value: p.id,
      child: Text('${p.name} (${p.durationDays}D)', maxLines: 1, overflow: TextOverflow.ellipsis),
    )).toList();

    if (_selectedPlanId != null && !planItems.any((item) => item.value == _selectedPlanId)) {
      planItems.insert(0, DropdownMenuItem<int>(
        value: _selectedPlanId!,
        child: Text(ms.planName ?? 'Plan #$_selectedPlanId'),
      ));
    }

    final safePlanValue = (_selectedPlanId != null && planItems.any((item) => item.value == _selectedPlanId))
        ? _selectedPlanId
        : null;

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
                    child: const Icon(Icons.autorenew_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Renew Membership', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text('${ms.memberName ?? 'Member'} (${ms.memberCode ?? '-'})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
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
              child: _isInitLoading
                  ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Previous Plan Banner
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.history_toggle_off_rounded, color: Color(0xFFD97706), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${ms.planName ?? 'Plan'} (ended ${ms.endDate.toIso8601String().split('T').first})',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Plan
                            DropdownButtonFormField<int?>(
                              initialValue: safePlanValue,
                              decoration: _inputDecoration('Renewal Plan *', icon: Icons.fitness_center_outlined),
                              items: planItems,
                              isExpanded: true,
                              onChanged: _onPlanChanged,
                              validator: (v) => v == null ? 'Choose a plan' : null,
                            ),
                            const SizedBox(height: 12),

                            // Start Date
                            _buildDateField('Start Date', Icons.event_available_outlined, _startDate.toIso8601String().split('T').first, onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() {
                                  _startDate = picked;
                                  if (_selectedPlanId != null && _plans.isNotEmpty) {
                                    final p = _plans.firstWhere((p) => p.id == _selectedPlanId);
                                    _endDate = _startDate.add(Duration(days: p.durationDays));
                                  }
                                });
                              }
                            }),
                            const SizedBox(height: 12),

                            // End Date
                            _buildDateField('End Date', Icons.event_busy_outlined, _endDate.toIso8601String().split('T').first, valueColor: AppColors.primary),
                            const SizedBox(height: 12),

                            // Amount Paid
                            TextFormField(
                              controller: _paidAmountController,
                              decoration: _inputDecoration('Amount Paid', icon: Icons.payments_outlined),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),

                            // Payment Method
                            DropdownButtonFormField<String>(
                              initialValue: _paymentMethod,
                              decoration: _inputDecoration('Payment Method', icon: Icons.account_balance_wallet_outlined),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                                DropdownMenuItem(value: 'CARD', child: Text('Card')),
                                DropdownMenuItem(value: 'UPI', child: Text('UPI / QR')),
                                DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                              ],
                              onChanged: (v) => setState(() => _paymentMethod = v ?? 'CASH'),
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
                      onPressed: _isLoading ? null : _renew,
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.autorenew_rounded, size: 18),
                      label: const Text('Renew'),
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

  Widget _buildDateField(String label, IconData icon, String value, {VoidCallback? onTap, Color? valueColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration(label, icon: icon),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor))),
            if (onTap != null) const Icon(Icons.edit_calendar, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
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
