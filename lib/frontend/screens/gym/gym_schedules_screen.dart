import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_schedule_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/gym/add_edit_schedule_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymSchedulesScreen extends StatefulWidget {
  const GymSchedulesScreen({super.key});

  @override
  State<GymSchedulesScreen> createState() => _GymSchedulesScreenState();
}

class _GymSchedulesScreenState extends State<GymSchedulesScreen> {
  final GymApiService gymService = GymApiService();

  List<GymScheduleModel> _allSchedules = [];
  List<GymScheduleModel> _filteredSchedules = [];

  String _selectedTab = 'All';
  DateTime? _selectedDate;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await gymService.getSchedules(date: _selectedDate);
      if (!mounted) return;
      setState(() {
        _allSchedules = list;
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
    List<GymScheduleModel> list = List.from(_allSchedules);

    if (_selectedTab != 'All') {
      list = list.where((s) => s.status.toUpperCase() == _selectedTab.toUpperCase()).toList();
    }

    setState(() {
      _filteredSchedules = list;
    });
  }

  Future<void> _deleteSchedule(GymScheduleModel schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Session', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete session "${schedule.title}"?'),
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
        await gymService.deleteSchedule(schedule.id!);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Schedule deleted successfully');
        loadSchedules();
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
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Schedules', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Schedules'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadSchedules,
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
                                    'Gym Sessions & Schedules',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Plan workout classes, trainer schedules, and group bootcamps', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AddEditScheduleDialog(onSaved: loadSchedules),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ Add Session'),
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

                          // Filter Row
                          Row(
                            children: [
                              _buildTabPill('All', _allSchedules.length),
                              const SizedBox(width: 8),
                              _buildTabPill('SCHEDULED', _allSchedules.where((s) => s.status.toUpperCase() == 'SCHEDULED').length),
                              const SizedBox(width: 8),
                              _buildTabPill('COMPLETED', _allSchedules.where((s) => s.status.toUpperCase() == 'COMPLETED').length),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_isLoading) ...[
                            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primary)))
                          ] else if (_error != null) ...[
                            _buildErrorBanner(),
                          ] else if (_filteredSchedules.isEmpty) ...[
                            _buildEmptyState(),
                          ] else ...[
                            _buildSchedulesList(),
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

  Widget _buildTabPill(String title, int count) {
    final isSelected = _selectedTab == title;

    return InkWell(
      onTap: () {
        setState(() => _selectedTab = title);
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
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
          TextButton(onPressed: loadSchedules, child: const Text('Retry')),
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
            child: const Icon(Icons.schedule_rounded, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('No workout sessions scheduled', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Schedule gym classes, personal training time slots or group sessions.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildSchedulesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSchedules.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = _filteredSchedules[index];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.alarm_on_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                      'Trainer: ${s.trainerName ?? "Staff"}  •  Date: ${s.date.toIso8601String().split("T").first} (${s.startTime} - ${s.endTime})',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    if (s.description != null) ...[
                      const SizedBox(height: 4),
                      Text(s.description!, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ],
                ),
              ),

              _buildStatusBadge(s.status),
              const SizedBox(width: 10),

              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                onPressed: () {
                  showDialog(context: context, builder: (_) => AddEditScheduleDialog(schedule: s, onSaved: loadSchedules));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                onPressed: () => _deleteSchedule(s),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF2563EB);
        break;
      case 'COMPLETED':
        bg = AppColors.successLight;
        text = AppColors.successText;
        break;
      case 'CANCELLED':
        bg = AppColors.dangerLight;
        text = AppColors.dangerText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }
}
