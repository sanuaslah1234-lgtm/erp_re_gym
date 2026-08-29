import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/employee_model.dart';
import 'package:erp_software/frontend/services/employee_service.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddEditTrainerDialog extends StatefulWidget {
  final GymTrainerModel? trainer;
  final VoidCallback onSaved;

  const AddEditTrainerDialog({
    super.key,
    this.trainer,
    required this.onSaved,
  });

  @override
  State<AddEditTrainerDialog> createState() => _AddEditTrainerDialogState();
}

class _AddEditTrainerDialogState extends State<AddEditTrainerDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();
  final EmployeeService employeeService = EmployeeService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _specializationController;
  late TextEditingController _experienceController;
  late TextEditingController _salaryController;

  int? _selectedEmployeeId;
  String _status = 'ACTIVE';
  List<EmployeeModel> _employees = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    final t = widget.trainer;
    _nameController = TextEditingController(text: t?.name ?? '');
    _phoneController = TextEditingController(text: t?.phone ?? '');
    _emailController = TextEditingController(text: t?.email ?? '');
    _specializationController = TextEditingController(text: t?.specialization ?? 'Strength & Bodybuilding');
    _experienceController = TextEditingController(text: t?.experience ?? '3 Years');
    _salaryController = TextEditingController(text: (t?.salary ?? 0.0).toStringAsFixed(2));
    _selectedEmployeeId = t?.employeeId;
    if (t != null) _status = t.status;
    _loadEmployees();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final emps = await employeeService.getEmployees();
      if (!mounted) return;
      setState(() {
        _employees = emps;
        _isInitLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  void _onEmployeeSelected(int? empId) {
    setState(() {
      _selectedEmployeeId = empId;
      if (empId != null) {
        final e = _employees.firstWhere((emp) => int.tryParse(emp.id ?? '') == empId, orElse: () => _employees.first);
        _nameController.text = e.fullName ?? '';
        _phoneController.text = e.phone;
        _emailController.text = e.email;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final trainer = GymTrainerModel(
        id: widget.trainer?.id,
        employeeId: _selectedEmployeeId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        specialization: _specializationController.text.trim(),
        experience: _experienceController.text.trim().isEmpty ? null : _experienceController.text.trim(),
        salary: double.tryParse(_salaryController.text.trim()) ?? 0.0,
        status: _status,
      );

      if (widget.trainer == null) {
        await gymService.createTrainer(trainer);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Trainer "${trainer.name}" added successfully', title: 'Trainer Added');
      } else {
        await gymService.updateTrainer(widget.trainer!.id!, trainer);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Trainer "${trainer.name}" updated successfully', title: 'Trainer Updated');
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
    final isEdit = widget.trainer != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: 600,
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
                    child: Icon(isEdit ? Icons.edit_note_rounded : Icons.sports_gymnastics_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Trainer' : 'Add Gym Trainer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text(isEdit ? 'Update specialization and salary' : 'Link to ERP Employee or enter new trainer profile', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                          if (_employees.isNotEmpty) ...[
                            DropdownButtonFormField<int>(
                              initialValue: _selectedEmployeeId,
                              decoration: _inputDecoration('Link to ERP Employee (Optional)', icon: Icons.badge_outlined),
                              items: [
                                const DropdownMenuItem<int>(value: null, child: Text('None (Direct Trainer)')),
                                ..._employees.map((e) => DropdownMenuItem<int>(
                                  value: int.tryParse(e.id ?? ''),
                                  child: Text('${e.fullName ?? "Employee"} (${(e.role ?? "Staff").toUpperCase()} - ${e.employeeId ?? ""})'),
                                )),
                              ],
                              onChanged: _onEmployeeSelected,
                            ),
                            const SizedBox(height: 14),
                          ],

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: _inputDecoration('Trainer Name *', icon: Icons.person_outline),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: _inputDecoration('Phone Number', icon: Icons.phone_outlined),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _specializationController,
                                  decoration: _inputDecoration('Specialization (Cardio, Weights, Yoga) *', icon: Icons.fitness_center_outlined),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Specialization required' : null,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextFormField(
                                  controller: _experienceController,
                                  decoration: _inputDecoration('Experience (e.g. 5 Years)', icon: Icons.timeline_outlined),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _salaryController,
                                  decoration: _inputDecoration('Monthly Salary / Retainer (\$)', icon: Icons.attach_money),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _status,
                                  decoration: _inputDecoration('Status', icon: Icons.toggle_on_outlined),
                                  items: const [
                                    DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                                    DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                                  ],
                                  onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
                                ),
                              ),
                            ],
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
                    label: Text(isEdit ? 'Save Changes' : 'Add Trainer'),
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
