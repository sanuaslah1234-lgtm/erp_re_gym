import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_workout_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/gym/add_edit_workout_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymWorkoutsScreen extends StatefulWidget {
  const GymWorkoutsScreen({super.key});

  @override
  State<GymWorkoutsScreen> createState() => _GymWorkoutsScreenState();
}

class _GymWorkoutsScreenState extends State<GymWorkoutsScreen> {
  final GymApiService gymService = GymApiService();

  List<WorkoutPlanModel> _allWorkouts = [];
  List<WorkoutPlanModel> _filteredWorkouts = [];

  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await gymService.getWorkoutPlans();
      if (!mounted) return;
      setState(() {
        _allWorkouts = list;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<WorkoutPlanModel> list = List.from(_allWorkouts);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((w) {
        return w.name.toLowerCase().contains(q) ||
            (w.memberName?.toLowerCase().contains(q) ?? false) ||
            (w.goal?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    setState(() {
      _filteredWorkouts = list;
    });
  }

  Future<void> _deleteWorkout(WorkoutPlanModel workout) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Workout Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${workout.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await gymService.deleteWorkoutPlan(workout.id!);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Workout plan deleted successfully');
        loadWorkouts();
      } catch (e) {
        if (!mounted) return;
        ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Workouts', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Workouts'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadWorkouts,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Member Workout Plans',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Custom workout programs, exercises, muscle groups, and routines', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AddEditWorkoutDialog(onSaved: loadWorkouts),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ Create Workout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Search
                          TextField(
                            onChanged: (v) {
                              setState(() => _searchQuery = v);
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search workouts by plan title, member name, goal...',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_isLoading) ...[
                            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primary)))
                          ] else if (_error != null) ...[
                            _buildErrorBanner(),
                          ] else if (_filteredWorkouts.isEmpty) ...[
                            _buildEmptyState(),
                          ] else ...[
                            _buildWorkoutsList(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
          TextButton(onPressed: loadWorkouts, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: const Icon(Icons.fitness_center_rounded, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('No workout programs created', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Design personalized workout routines and assign exercises to members.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredWorkouts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final w = _filteredWorkouts[index];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                            const SizedBox(width: 10),
                            if (w.goal != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                child: Text('Goal: ${w.goal!}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Member: ${w.memberName ?? "Member"}  •  Trainer: ${w.trainerName ?? "Self-Guided"}  •  Started: ${w.startDate.toIso8601String().split("T").first}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                    onPressed: () {
                      showDialog(context: context, builder: (_) => AddEditWorkoutDialog(workoutPlan: w, onSaved: loadWorkouts));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    onPressed: () => _deleteWorkout(w),
                  ),
                ],
              ),

              if (w.exercises.isNotEmpty) ...[
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                const Text('Assigned Exercises Routine:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: w.exercises.map((ex) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(ex.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                          const SizedBox(width: 6),
                          Text('(${ex.sets}×${ex.reps})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
