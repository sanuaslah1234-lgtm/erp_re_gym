import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_schedule_model.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddEditScheduleDialog extends StatefulWidget {
  final GymScheduleModel? schedule;
  final VoidCallback onSaved;

  const AddEditScheduleDialog({
    super.key,
    this.schedule,
    required this.onSaved,
  });

  @override
  State<AddEditScheduleDialog> createState() => _AddEditScheduleDialogState();
}

class _AddEditScheduleDialogState extends State<AddEditScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  int? _selectedTrainerId;
  DateTime _date = DateTime.now();
  String _status = 'SCHEDULED';

  List<GymTrainerModel> _trainers = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _titleController = TextEditingController(text: s?.title ?? 'Morning Cardio & HIIT');
    _descriptionController = TextEditingController(text: s?.description ?? 'High intensity cardio training session');
    _startTimeController = TextEditingController(text: s?.startTime ?? '07:00 AM');
    _endTimeController = TextEditingController(text: s?.endTime ?? '08:30 AM');
    _selectedTrainerId = s?.trainerId;
    if (s != null) {
      _date = s.date;
      _status = s.status;
    }
    _loadTrainers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainers() async {
    try {
      final trainers = await gymService.getTrainers();
      if (!mounted) return;
      setState(() {
        _trainers = trainers;
        _isInitLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final schedule = GymScheduleModel(
        id: widget.schedule?.id,
        trainerId: _selectedTrainerId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        date: _date,
        status: _status,
      );

      if (widget.schedule == null) {
        await gymService.createSchedule(schedule);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Schedule created successfully', title: 'Schedule Added');
      } else {
        await gymService.updateSchedule(widget.schedule!.id!, schedule);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Schedule updated successfully', title: 'Schedule Updated');
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
    final isEdit = widget.schedule != null;

    final trainerItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('No Specific Trainer')),
      ..._trainers.map((t) => DropdownMenuItem<int?>(
        value: t.id,
        child: Text('${t.name} (${t.specialization})'),
      )),
    ];

    if (_selectedTrainerId != null && !trainerItems.any((item) => item.value == _selectedTrainerId)) {
      trainerItems.add(DropdownMenuItem<int?>(
        value: _selectedTrainerId,
        child: Text(widget.schedule?.trainerName ?? 'Trainer #$_selectedTrainerId'),
      ));
    }

    final safeTrainerValue = (_selectedTrainerId == null || trainerItems.any((item) => item.value == _selectedTrainerId))
        ? _selectedTrainerId
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 580,
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
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Class / Schedule' : 'Schedule New Class / Session', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const Text('Set up gym training sessions and assign trainers', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                            TextFormField(
                              controller: _titleController,
                              decoration: _inputDecoration('Session Title *', icon: Icons.title_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                            ),
                            const SizedBox(height: 14),

                            DropdownButtonFormField<int?>(
                              initialValue: safeTrainerValue,
                              decoration: _inputDecoration('Trainer in Charge', icon: Icons.sports_gymnastics_rounded),
                              items: trainerItems,
                              onChanged: (v) => setState(() => _selectedTrainerId = v),
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _date,
                                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                        lastDate: DateTime.now().add(const Duration(days: 180)),
                                      );
                                      if (picked != null) setState(() => _date = picked);
                                    },
                                    child: InputDecorator(
                                      decoration: _inputDecoration('Session Date', icon: Icons.event_outlined),
                                      child: Text(_date.toIso8601String().split('T').first, style: const TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _status,
                                    decoration: _inputDecoration('Status', icon: Icons.toggle_on_outlined),
                                    items: const [
                                      DropdownMenuItem(value: 'SCHEDULED', child: Text('SCHEDULED')),
                                      DropdownMenuItem(value: 'ONGOING', child: Text('ONGOING')),
                                      DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                                      DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                                    ],
                                    onChanged: (v) => setState(() => _status = v ?? 'SCHEDULED'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _startTimeController,
                                    decoration: _inputDecoration('Start Time', icon: Icons.access_time),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextFormField(
                                    controller: _endTimeController,
                                    decoration: _inputDecoration('End Time', icon: Icons.access_time_filled),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 2,
                              decoration: _inputDecoration('Description / Objectives', icon: Icons.description_outlined),
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
                    onPressed: _isLoading ? null : _save,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 18),
                    label: Text(isEdit ? 'Save Changes' : 'Schedule Session'),
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
