import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddMembershipDialog extends StatefulWidget {
  final int? preselectedMemberId;
  final VoidCallback onSaved;

  const AddMembershipDialog({
    super.key,
    this.preselectedMemberId,
    required this.onSaved,
  });

  @override
  State<AddMembershipDialog> createState() => _AddMembershipDialogState();
}

class _AddMembershipDialogState extends State<AddMembershipDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();

  int? _selectedMemberId;
  int? _selectedPlanId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final bool _autoRenew = false;
  String _paymentMethod = 'CASH';

  late TextEditingController _amountController;
  late TextEditingController _discountController;
  late TextEditingController _taxController;
  late TextEditingController _paidAmountController;

  List<GymMemberModel> _members = [];
  List<GymPlanModel> _plans = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMemberId = widget.preselectedMemberId;
    _amountController = TextEditingController(text: '0.00');
    _discountController = TextEditingController(text: '0.00');
    _taxController = TextEditingController(text: '0.00');
    _paidAmountController = TextEditingController(text: '0.00');
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final members = await gymService.getMembers();
      final plans = await gymService.getPlans(status: 'ACTIVE');

      if (!mounted) return;
      setState(() {
        _members = members;
        _plans = plans;
        if (_plans.isNotEmpty) {
          _onPlanChanged(_plans.first.id);
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
      if (planId != null) {
        final plan = _plans.firstWhere((p) => p.id == planId, orElse: () => _plans.first);
        _endDate = _startDate.add(Duration(days: plan.durationDays));
        _amountController.text = plan.price.toStringAsFixed(2);
        _discountController.text = plan.discount.toStringAsFixed(2);
        _taxController.text = plan.tax.toStringAsFixed(2);
        _paidAmountController.text = plan.totalAmount.toStringAsFixed(2);
      }
    });
  }

  double get _finalAmount {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final disc = double.tryParse(_discountController.text.trim()) ?? 0.0;
    final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
    return (amt - disc + tax).clamp(0.0, 9999999.0);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ErpToast.showError(context, 'Please select a member');
      return;
    }
    if (_selectedPlanId == null) {
      ErpToast.showError(context, 'Please select a plan');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final membership = GymMembershipModel(
        memberId: _selectedMemberId!,
        planId: _selectedPlanId!,
        startDate: _startDate,
        endDate: _endDate,
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
        discount: double.tryParse(_discountController.text.trim()) ?? 0.0,
        tax: double.tryParse(_taxController.text.trim()) ?? 0.0,
        finalAmount: _finalAmount,
        status: 'ACTIVE',
        autoRenew: _autoRenew,
      );

      final paid = double.tryParse(_paidAmountController.text.trim());

      await gymService.createMembership(
        membership,
        paidAmount: paid,
        paymentMethod: _paymentMethod,
      );

      if (!mounted) return;
      ErpToast.showSuccess(context, 'Membership activated and invoice generated!', title: 'Membership Created');
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: 650,
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
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.card_membership_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Activate New Membership', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Assign plan, calculate duration and record initial payment', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                          // Member Selection
                          DropdownButtonFormField<int>(
                            initialValue: _selectedMemberId,
                            decoration: _inputDecoration('Select Gym Member *', icon: Icons.person_outline),
                            items: _members.map((m) {
                              return DropdownMenuItem<int>(
                                value: m.id,
                                child: Text('${m.name} (${m.memberCode} - ${m.phone})'),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedMemberId = v),
                            validator: (v) => v == null ? 'Please choose a member' : null,
                          ),
                          const SizedBox(height: 14),

                          // Plan Selection
                          DropdownButtonFormField<int>(
                            initialValue: _selectedPlanId,
                            decoration: _inputDecoration('Select Membership Plan *', icon: Icons.fitness_center_outlined),
                            items: _plans.map((p) {
                              return DropdownMenuItem<int>(
                                value: p.id,
                                child: Text('${p.name} (${p.durationDays} Days - \$${p.totalAmount.toStringAsFixed(0)})'),
                              );
                            }).toList(),
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
                                        if (_selectedPlanId != null) {
                                          final plan = _plans.firstWhere((p) => p.id == _selectedPlanId);
                                          _endDate = _startDate.add(Duration(days: plan.durationDays));
                                        }
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: _inputDecoration('Start Date', icon: Icons.event_available_outlined),
                                    child: Text(_startDate.toIso8601String().split('T').first, style: const TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: InputDecorator(
                                  decoration: _inputDecoration('Calculated End Date', icon: Icons.event_busy_outlined),
                                  child: Text(_endDate.toIso8601String().split('T').first, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Price Breakdown Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _amountController,
                                  decoration: _inputDecoration('Base Price (\$)', icon: Icons.attach_money),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _discountController,
                                  decoration: _inputDecoration('Discount (\$)', icon: Icons.discount_outlined),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _taxController,
                                  decoration: _inputDecoration('Tax (\$)', icon: Icons.receipt_outlined),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
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
                                  decoration: _inputDecoration('Amount Paid Now (\$)', icon: Icons.payments_outlined),
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
                          const SizedBox(height: 16),

                          // Summary Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Membership Fee', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                Text('\$${_finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                              ],
                            ),
                          ),
                        ],
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
                    onPressed: _isLoading ? null : _save,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Activate Membership'),
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
