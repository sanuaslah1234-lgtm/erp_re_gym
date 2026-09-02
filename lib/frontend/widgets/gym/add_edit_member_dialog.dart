import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/customer_model.dart';
import 'package:erp_software/frontend/services/customer_service.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddEditMemberDialog extends StatefulWidget {
  final GymMemberModel? member;
  final VoidCallback onSaved;

  const AddEditMemberDialog({
    super.key,
    this.member,
    required this.onSaved,
  });

  @override
  State<AddEditMemberDialog> createState() => _AddEditMemberDialogState();
}

class _AddEditMemberDialogState extends State<AddEditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();
  final CustomerService customerService = CustomerService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _memberCodeController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _paidAmountController;

  String _gender = 'Male';
  String _status = 'ACTIVE';
  DateTime? _dateOfBirth;
  DateTime _joinDate = DateTime.now();

  String? _selectedCustomerId;
  int? _selectedPlanId;
  int? _selectedTrainerId;
  String _paymentMethod = 'CASH';

  List<GymPlanModel> _plans = [];
  List<GymTrainerModel> _trainers = [];
  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nameController = TextEditingController(text: m?.name ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _memberCodeController = TextEditingController(text: m?.memberCode ?? '');
    _addressController = TextEditingController(text: m?.address ?? '');
    _emergencyContactController = TextEditingController(text: m?.emergencyContact ?? '');
    _paidAmountController = TextEditingController(text: '');

    if (m != null) {
      _gender = m.gender ?? 'Male';
      _status = m.status;
      _dateOfBirth = m.dateOfBirth;
      _joinDate = m.joinDate;
      _selectedCustomerId = m.customerId?.toString();
    }

    _loadDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _memberCodeController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadDependencies() async {
    try {
      final results = await Future.wait([
        gymService.getPlans(),
        gymService.getTrainers(),
        customerService.getCustomers(),
      ]);

      if (!mounted) return;
      setState(() {
        _plans = results[0] as List<GymPlanModel>;
        _trainers = results[1] as List<GymTrainerModel>;
        _customers = results[2] as List<CustomerModel>;
        _isInitLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  void _onCustomerSelected(String? customerId) {
    setState(() {
      _selectedCustomerId = customerId;
      if (customerId != null) {
        final c = _customers.firstWhere((c) => c.id?.toString() == customerId, orElse: () => _customers.first);
        if (_nameController.text.isEmpty) _nameController.text = c.name;
        if (_phoneController.text.isEmpty) _phoneController.text = c.phone;
        if (_emailController.text.isEmpty && c.email != null) _emailController.text = c.email!;
        if (_addressController.text.isEmpty && c.address != null) _addressController.text = c.address!;
      }
    });
  }

  void _onPlanSelected(int? planId) {
    setState(() {
      _selectedPlanId = planId;
      if (planId != null) {
        final p = _plans.firstWhere((p) => p.id == planId, orElse: () => _plans.first);
        _paidAmountController.text = p.totalAmount.toStringAsFixed(2);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final member = GymMemberModel(
        id: widget.member?.id,
        memberCode: _memberCodeController.text.trim(),
        customerId: _selectedCustomerId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
        joinDate: _joinDate,
        status: _status,
      );

      if (widget.member == null) {
        final paid = double.tryParse(_paidAmountController.text.trim());
        await gymService.createMember(
          member,
          planId: _selectedPlanId,
          paidAmount: paid,
          paymentMethod: _paymentMethod,
          trainerId: _selectedTrainerId,
        );
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Member "${member.name}" added successfully', title: 'Member Registered');
      } else {
        await gymService.updateMember(widget.member!.id!, member);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Member "${member.name}" updated successfully', title: 'Member Updated');
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
    final isEdit = widget.member != null;

    final customerItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('None (Create fresh member record)')),
      ..._customers.map((c) => DropdownMenuItem<String?>(
            value: c.id?.toString(),
            child: Text('${c.name} (${c.phone})'),
          )),
    ];

    if (_selectedCustomerId != null && !customerItems.any((item) => item.value == _selectedCustomerId)) {
      customerItems.add(DropdownMenuItem<String?>(
        value: _selectedCustomerId,
        child: Text('Customer #$_selectedCustomerId'),
      ));
    }

    final planItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('No plan (Assign later)')),
      ..._plans.map((p) => DropdownMenuItem<int?>(
            value: p.id,
            child: Text('${p.name} (${p.durationDays}d - \$${p.totalAmount.toStringAsFixed(0)})'),
          )),
    ];

    if (_selectedPlanId != null && !planItems.any((item) => item.value == _selectedPlanId)) {
      planItems.add(DropdownMenuItem<int?>(
        value: _selectedPlanId,
        child: Text('Plan #$_selectedPlanId'),
      ));
    }

    final trainerItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('No Trainer')),
      ..._trainers.map((t) => DropdownMenuItem<int?>(
            value: t.id,
            child: Text('${t.name} (${t.specialization})'),
          )),
    ];

    if (_selectedTrainerId != null && !trainerItems.any((item) => item.value == _selectedTrainerId)) {
      trainerItems.add(DropdownMenuItem<int?>(
        value: _selectedTrainerId,
        child: Text('Trainer #$_selectedTrainerId'),
      ));
    }

    final safeCustomerValue = (_selectedCustomerId == null || customerItems.any((item) => item.value == _selectedCustomerId))
        ? _selectedCustomerId
        : null;

    final safePlanValue = (_selectedPlanId == null || planItems.any((item) => item.value == _selectedPlanId))
        ? _selectedPlanId
        : null;

    final safeTrainerValue = (_selectedTrainerId == null || trainerItems.any((item) => item.value == _selectedTrainerId))
        ? _selectedTrainerId
        : null;

    const genderList = ['Male', 'Female', 'Other'];
    final safeGenderValue = genderList.contains(_gender) ? _gender : 'Male';

    const statusList = ['ACTIVE', 'INACTIVE', 'EXPIRED', 'SUSPENDED'];
    final safeStatusValue = statusList.contains(_status) ? _status : 'ACTIVE';

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth - 40).clamp(320.0, 600.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                    child: Icon(isEdit ? Icons.edit_note_rounded : Icons.person_add_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Gym Member' : 'Register New Gym Member',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          isEdit ? 'Update member details and preferences' : 'Add member info, assign plan and trainer',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
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

            // Body
            Expanded(
              child: _isInitLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section: Customer Linking
                            if (!isEdit && _customers.isNotEmpty) ...[
                              _buildSectionTitle('1. ERP Customer Link (Optional)'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String?>(
                                initialValue: safeCustomerValue,
                                decoration: _inputDecoration('Select Customer (Optional)', icon: Icons.business_outlined),
                                isExpanded: true,
                                items: customerItems,
                                onChanged: _onCustomerSelected,
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Section: Personal Information
                            _buildSectionTitle(isEdit ? '1. Personal Information' : '2. Personal Information'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration('Full Name *', icon: Icons.person_outline),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              decoration: _inputDecoration('Phone Number *', icon: Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration('Email Address', icon: Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: safeGenderValue,
                              decoration: _inputDecoration('Gender', icon: Icons.wc_outlined),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                                DropdownMenuItem(value: 'Female', child: Text('Female')),
                                DropdownMenuItem(value: 'Other', child: Text('Other')),
                              ],
                              onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dateOfBirth ?? DateTime(2000, 1, 1),
                                  firstDate: DateTime(1940),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) setState(() => _dateOfBirth = picked);
                              },
                              child: InputDecorator(
                                decoration: _inputDecoration('Date of Birth', icon: Icons.cake_outlined),
                                child: Text(
                                  _dateOfBirth != null ? _dateOfBirth!.toIso8601String().split('T').first : 'Select DOB',
                                  style: TextStyle(color: _dateOfBirth != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8), fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emergencyContactController,
                              decoration: _inputDecoration('Emergency Contact', icon: Icons.contact_phone_outlined),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: _inputDecoration('Residential Address', icon: Icons.home_outlined),
                            ),
                            const SizedBox(height: 20),

                            // Section: Membership & Gym Details
                            _buildSectionTitle(isEdit ? '2. Membership & Status' : '3. Initial Membership & Plan'),
                            const SizedBox(height: 12),

                            if (!isEdit) ...[
                              DropdownButtonFormField<int?>(
                                initialValue: safePlanValue,
                                decoration: _inputDecoration('Membership Plan', icon: Icons.card_membership_outlined),
                                isExpanded: true,
                                items: planItems,
                                onChanged: _onPlanSelected,
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<int?>(
                                initialValue: safeTrainerValue,
                                decoration: _inputDecoration('Assign Trainer (Optional)', icon: Icons.fitness_center_outlined),
                                isExpanded: true,
                                items: trainerItems,
                                onChanged: (v) => setState(() => _selectedTrainerId = v),
                              ),
                              if (_selectedPlanId != null) ...[
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _paidAmountController,
                                  decoration: _inputDecoration('Payment Amount', icon: Icons.payments_outlined),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 14),
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
                            ],

                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: safeStatusValue,
                              decoration: _inputDecoration('Member Status', icon: Icons.toggle_on_outlined),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                                DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                                DropdownMenuItem(value: 'EXPIRED', child: Text('EXPIRED')),
                                DropdownMenuItem(value: 'SUSPENDED', child: Text('SUSPENDED')),
                              ],
                              onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _joinDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (picked != null) setState(() => _joinDate = picked);
                              },
                              child: InputDecorator(
                                decoration: _inputDecoration('Join Date', icon: Icons.event_outlined),
                                child: Text(_joinDate.toIso8601String().split('T').first, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _save,
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check, size: 18),
                      label: Text(isEdit ? 'Save' : 'Register', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2563EB),
        letterSpacing: 0.3,
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
