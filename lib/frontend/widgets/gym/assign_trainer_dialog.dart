import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AssignTrainerDialog extends StatefulWidget {
  final int? preselectedTrainerId;
  final String? preselectedTrainerName;
  final int? preselectedMemberId;
  final VoidCallback onAssigned;

  const AssignTrainerDialog({
    super.key,
    this.preselectedTrainerId,
    this.preselectedTrainerName,
    this.preselectedMemberId,
    required this.onAssigned,
  });

  @override
  State<AssignTrainerDialog> createState() => _AssignTrainerDialogState();
}

class _AssignTrainerDialogState extends State<AssignTrainerDialog> {
  final GymApiService gymService = GymApiService();

  int? _selectedTrainerId;
  int? _selectedMemberId;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  List<GymTrainerModel> _trainers = [];
  List<GymMemberModel> _members = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTrainerId = widget.preselectedTrainerId;
    _selectedMemberId = widget.preselectedMemberId;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        gymService.getTrainers(),
        gymService.getMembers(),
      ]);

      if (!mounted) return;
      setState(() {
        _trainers = results[0] as List<GymTrainerModel>;
        _members = results[1] as List<GymMemberModel>;
        _isInitLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  Future<void> _save() async {
    if (_selectedTrainerId == null) {
      ErpToast.showError(context, 'Please select a trainer');
      return;
    }
    if (_selectedMemberId == null) {
      ErpToast.showError(context, 'Please select a member');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await gymService.assignMemberToTrainer(
        _selectedTrainerId!,
        _selectedMemberId!,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;
      ErpToast.showSuccess(context, 'Member successfully assigned to personal trainer!', title: 'Trainer Assigned');
      widget.onAssigned();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth - 40).clamp(320.0, 500.0);
    final trainerItems = _trainers.map((t) => DropdownMenuItem<int>(
      value: t.id,
      child: Text('${t.name} (${t.specialization})'),
    )).toList();

    if (_selectedTrainerId != null && !trainerItems.any((item) => item.value == _selectedTrainerId)) {
      trainerItems.insert(0, DropdownMenuItem<int>(
        value: _selectedTrainerId!,
        child: Text(widget.preselectedTrainerName ?? 'Trainer #$_selectedTrainerId'),
      ));
    }

    final memberItems = _members.map((m) => DropdownMenuItem<int>(
      value: m.id,
      child: Text('${m.name} (${m.memberCode})'),
    )).toList();

    if (_selectedMemberId != null && !memberItems.any((item) => item.value == _selectedMemberId)) {
      memberItems.insert(0, DropdownMenuItem<int>(
        value: _selectedMemberId!,
        child: Text('Member #$_selectedMemberId'),
      ));
    }

    final safeTrainerValue = (_selectedTrainerId != null && trainerItems.any((item) => item.value == _selectedTrainerId))
        ? _selectedTrainerId
        : null;

    final safeMemberValue = (_selectedMemberId != null && memberItems.any((item) => item.value == _selectedMemberId))
        ? _selectedMemberId
        : null;

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
                    child: const Icon(Icons.assignment_ind_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assign Trainer to Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Connect member for personalized training coaching', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trainer selector
                        DropdownButtonFormField<int?>(
                          initialValue: safeTrainerValue,
                          decoration: _inputDecoration('Trainer *', icon: Icons.sports_gymnastics_rounded),
                          isExpanded: true,
                          items: trainerItems,
                          onChanged: (v) => setState(() => _selectedTrainerId = v),
                        ),
                        const SizedBox(height: 14),

                        // Member selector
                        DropdownButtonFormField<int?>(
                          initialValue: safeMemberValue,
                          decoration: _inputDecoration('Member *', icon: Icons.person_outline),
                          isExpanded: true,
                          items: memberItems,
                          onChanged: (v) => setState(() => _selectedMemberId = v),
                        ),
                        const SizedBox(height: 14),

                        // Dates
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
                                  if (picked != null) setState(() => _startDate = picked);
                                },
                                child: InputDecorator(
                                  decoration: _inputDecoration('Start Date', icon: Icons.event_available_outlined),
                                  child: Text(_startDate.toIso8601String().split('T').first, style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? _startDate.add(const Duration(days: 90)),
                                    firstDate: _startDate,
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) setState(() => _endDate = picked);
                                },
                                child: InputDecorator(
                                  decoration: _inputDecoration('End Date (Optional)', icon: Icons.event_busy_outlined),
                                  child: Text(_endDate != null ? _endDate!.toIso8601String().split('T').first : 'No End Date', style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                      label: const Text('Assign', style: TextStyle(fontWeight: FontWeight.bold)),
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
