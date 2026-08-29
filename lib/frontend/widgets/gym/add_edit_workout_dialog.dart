import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/gym/gym_workout_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class AddEditWorkoutDialog extends StatefulWidget {
  final WorkoutPlanModel? workoutPlan;
  final int? preselectedMemberId;
  final VoidCallback onSaved;

  const AddEditWorkoutDialog({
    super.key,
    this.workoutPlan,
    this.preselectedMemberId,
    required this.onSaved,
  });

  @override
  State<AddEditWorkoutDialog> createState() => _AddEditWorkoutDialogState();
}

class _AddEditWorkoutDialogState extends State<AddEditWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final GymApiService gymService = GymApiService();

  int? _selectedMemberId;
  int? _selectedTrainerId;
  late TextEditingController _nameController;
  late TextEditingController _goalController;
  late TextEditingController _notesController;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<WorkoutExerciseModel> _exercises = [];
  List<GymMemberModel> _members = [];
  List<GymTrainerModel> _trainers = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    final wp = widget.workoutPlan;
    _selectedMemberId = wp?.memberId ?? widget.preselectedMemberId;
    _selectedTrainerId = wp?.trainerId;
    _nameController = TextEditingController(text: wp?.name ?? 'Muscle Building & Strength');
    _goalController = TextEditingController(text: wp?.goal ?? 'Hypertrophy & Core');
    _notesController = TextEditingController(text: wp?.notes ?? '');
    if (wp != null) {
      _startDate = wp.startDate;
      _endDate = wp.endDate;
      _exercises.addAll(wp.exercises);
    } else {
      // Add a couple default exercise lines for quick convenience
      _exercises.add(WorkoutExerciseModel(exerciseName: 'Barbell Bench Press', muscleGroup: 'Chest', sets: 4, reps: '8-10', weight: '60 kg'));
      _exercises.add(WorkoutExerciseModel(exerciseName: 'Lat Pulldown', muscleGroup: 'Back', sets: 3, reps: '10-12', weight: '45 kg'));
      _exercises.add(WorkoutExerciseModel(exerciseName: 'Barbell Squats', muscleGroup: 'Legs', sets: 4, reps: '8-10', weight: '75 kg'));
    }
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final members = await gymService.getMembers(status: 'ACTIVE');
      final trainers = await gymService.getTrainers(status: 'ACTIVE');
      if (!mounted) return;
      setState(() {
        _members = members;
        _trainers = trainers;
        _isInitLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  void _addExerciseDialog() {
    final nameCtrl = TextEditingController();
    String muscle = 'Chest';
    int sets = 3;
    final repsCtrl = TextEditingController(text: '10-12');
    final weightCtrl = TextEditingController(text: '20 kg');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Exercise Name (e.g. Incline Dumbbell Press)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: muscle,
                    decoration: const InputDecoration(labelText: 'Target Muscle Group'),
                    items: const [
                      DropdownMenuItem(value: 'Chest', child: Text('Chest')),
                      DropdownMenuItem(value: 'Back', child: Text('Back')),
                      DropdownMenuItem(value: 'Legs', child: Text('Legs')),
                      DropdownMenuItem(value: 'Shoulders', child: Text('Shoulders')),
                      DropdownMenuItem(value: 'Arms', child: Text('Arms (Biceps/Triceps)')),
                      DropdownMenuItem(value: 'Core', child: Text('Core & Abs')),
                      DropdownMenuItem(value: 'Cardio', child: Text('Cardio & HIIT')),
                    ],
                    onChanged: (v) => setDialogState(() => muscle = v ?? 'Chest'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: sets,
                          decoration: const InputDecoration(labelText: 'Sets'),
                          items: [1, 2, 3, 4, 5, 6].map((s) => DropdownMenuItem(value: s, child: Text('$s sets'))).toList(),
                          onChanged: (v) => setDialogState(() => sets = v ?? 3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: repsCtrl,
                          decoration: const InputDecoration(labelText: 'Reps (e.g. 10-12)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: weightCtrl,
                    decoration: const InputDecoration(labelText: 'Target Weight (e.g. 25 kg)'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _exercises.add(WorkoutExerciseModel(
                          exerciseName: nameCtrl.text.trim(),
                          muscleGroup: muscle,
                          sets: sets,
                          reps: repsCtrl.text.trim(),
                          weight: weightCtrl.text.trim(),
                        ));
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ErpToast.showError(context, 'Please select a member');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final wp = WorkoutPlanModel(
        id: widget.workoutPlan?.id,
        memberId: _selectedMemberId!,
        trainerId: _selectedTrainerId,
        name: _nameController.text.trim(),
        goal: _goalController.text.trim().isEmpty ? null : _goalController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        exercises: _exercises,
      );

      if (widget.workoutPlan == null) {
        await gymService.createWorkoutPlan(wp);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Workout plan created successfully', title: 'Workout Created');
      } else {
        await gymService.updateWorkoutPlan(widget.workoutPlan!.id!, wp);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Workout plan updated successfully', title: 'Workout Updated');
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
    final isEdit = widget.workoutPlan != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 720,
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
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Workout Plan' : 'Create Member Workout Plan', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const Text('Define routine, target muscles, sets, reps and exercises', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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

            // Form Content
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
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    initialValue: _selectedMemberId,
                                    decoration: _inputDecoration('Select Member *', icon: Icons.person_outline),
                                    items: _members.map((m) => DropdownMenuItem<int>(
                                      value: m.id,
                                      child: Text('${m.name} (${m.memberCode})'),
                                    )).toList(),
                                    onChanged: (v) => setState(() => _selectedMemberId = v),
                                    validator: (v) => v == null ? 'Select member' : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    initialValue: _selectedTrainerId,
                                    decoration: _inputDecoration('Assigned Trainer', icon: Icons.sports_gymnastics_rounded),
                                    items: [
                                      const DropdownMenuItem<int>(value: null, child: Text('Self-Guided (No Trainer)')),
                                      ..._trainers.map((t) => DropdownMenuItem<int>(
                                        value: t.id,
                                        child: Text('${t.name} (${t.specialization})'),
                                      )),
                                    ],
                                    onChanged: (v) => setState(() => _selectedTrainerId = v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: _inputDecoration('Workout Plan Name *', icon: Icons.badge_outlined),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Plan name required' : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _goalController,
                                    decoration: _inputDecoration('Target Goal (e.g. Weight Loss)', icon: Icons.flag_outlined),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Exercises List Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Exercises Routine', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                OutlinedButton.icon(
                                  onPressed: _addExerciseDialog,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Exercise'),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (_exercises.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                child: const Center(child: Text('No exercises added yet. Click "+ Add Exercise" above.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13))),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _exercises.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final ex = _exercises[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                                          child: Text(ex.muscleGroup ?? 'Chest', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(ex.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                        ),
                                        Text('${ex.sets} sets × ${ex.reps}  ${ex.weight != null ? "(${ex.weight})" : ""}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                                          onPressed: () => setState(() => _exercises.removeAt(index)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
                    label: Text(isEdit ? 'Save Workout' : 'Create Workout'),
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
