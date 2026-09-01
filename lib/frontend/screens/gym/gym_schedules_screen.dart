import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_schedule_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
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
      final list = await gymService.getSchedules();
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
        content: Text('Delete "${schedule.title}"?'),
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
        ErpToast.showSuccess(context, 'Session deleted');
        loadSchedules();
      } catch (e) {
        if (!mounted) return;
        ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const HamburgerButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Schedules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        actions: [
          IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => AddEditScheduleDialog(onSaved: loadSchedules)),
            icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
            tooltip: 'Add Session',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadSchedules,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabPill('All', _allSchedules.length),
                    const SizedBox(width: 8),
                    _buildTabPill('SCHEDULED', _allSchedules.where((s) => s.status.toUpperCase() == 'SCHEDULED').length),
                    const SizedBox(width: 8),
                    _buildTabPill('COMPLETED', _allSchedules.where((s) => s.status.toUpperCase() == 'COMPLETED').length),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Content
              if (_isLoading)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else if (_error != null)
                _buildErrorBanner()
              else if (_filteredSchedules.isEmpty)
                _buildEmptyState()
              else
                ...(_filteredSchedules.map((s) => _scheduleCard(s))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scheduleCard(GymScheduleModel s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.alarm_on_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${s.trainerName ?? "Staff"} • ${s.date.toIso8601String().split('T').first}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _buildStatusBadge(s.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(Icons.access_time_rounded, '${s.startTime} - ${s.endTime}'),
              const Spacer(),
              IconButton(
                onPressed: () => showDialog(context: context, builder: (_) => AddEditScheduleDialog(schedule: s, onSaved: loadSchedules)),
                icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _deleteSchedule(s),
                icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (s.description != null && s.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(s.description!, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: const Color(0xFF64748B)),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF475569)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTabPill(String title, int count) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = title);
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF475569))),
            const SizedBox(width: 6),
            Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12))),
          TextButton(onPressed: loadSchedules, child: const Text('Retry', style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Icon(Icons.schedule_rounded, size: 40, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          const Text('No sessions scheduled', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          const Text('Add a session using the + button above.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
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
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
    );
  }
}
