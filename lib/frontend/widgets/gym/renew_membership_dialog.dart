import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class RenewMembershipDialog extends StatefulWidget {
  final GymMembershipModel membership;
  final VoidCallback onRenewed;

  const RenewMembershipDialog({
    super.key,
    required this.membership,
    required this.onRenewed,
  });

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
      ErpToast.showSuccess(context, 'Membership renewed successfully!', title: 'Renewal Complete');
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

    final planItems = _plans.map((p) => DropdownMenuItem<int>(
      value: p.id,
      child: Text('${p.name} (${p.durationDays} Days - \$${p.totalAmount.toStringAsFixed(0)})'),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 650,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
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
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.autorenew_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Renew Gym Membership', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Member: ${ms.memberName ?? 'Member'} (${ms.memberCode ?? '-'})', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
            Expanded(
              child: _isInitLoading
                  ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Previous Expiry Banner
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.history_toggle_off_rounded, color: Color(0xFFD97706), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Previous Plan: ${ms.planName ?? 'Standard'} (Ended on ${ms.endDate.toIso8601String().split('T').first})',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Plan Selection
                            DropdownButtonFormField<int>(
                              initialValue: safePlanValue,
                              decoration: _inputDecoration('Select Renewal Plan *', icon: Icons.fitness_center_outlined),
                              items: planItems,
                              onChanged: _onPlanChanged,
                              validator: (v) => v == null ? 'Please choose a plan' : null,
                            ),
                            const SizedBox(height: 14),

                            // Dates Row
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
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
                                    },
                                    child: InputDecorator(
                                      decoration: _inputDecoration('New Start Date', icon: Icons.event_available_outlined),
                                      child: Text(_startDate.toIso8601String().split('T').first, style: const TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: _inputDecoration('New End Date', icon: Icons.event_busy_outlined),
                                    child: Text(_endDate.toIso8601String().split('T').first, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Payment Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _paidAmountController,
                                    decoration: _inputDecoration('Amount Paid (\$)', icon: Icons.payments_outlined),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _paymentMethod,
                                    decoration: _inputDecoration('Payment Method', icon: Icons.account_balance_wallet_outlined),
                                    items: const [
                                      DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                                      DropdownMenuItem(value: 'CARD', child: Text('Credit / Debit Card')),
                                      DropdownMenuItem(value: 'UPI', child: Text('UPI / QR')),
                                      DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                                    ],
                                    onChanged: (v) => setState(() => _paymentMethod = v ?? 'CASH'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _renew,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.autorenew_rounded, size: 18),
                    label: const Text('Confirm Renewal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
