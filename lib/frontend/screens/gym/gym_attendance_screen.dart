import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_attendance_model.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymAttendanceScreen extends StatefulWidget {
  const GymAttendanceScreen({super.key});

  @override
  State<GymAttendanceScreen> createState() => _GymAttendanceScreenState();
}

class _GymAttendanceScreenState extends State<GymAttendanceScreen> {
  final GymApiService gymService = GymApiService();

  List<GymAttendanceModel> _todayAttendance = [];
  List<GymAttendanceModel> _historyAttendance = [];
  List<GymMemberModel> _allMembers = [];

  String _selectedTab = 'Today';
  int? _quickCheckInMemberId;
  DateTime _historyDate = DateTime.now();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final today = await gymService.getTodayAttendance();
      final history = await gymService.getAttendance(date: _historyDate);
      final members = await gymService.getMembers(status: 'ACTIVE');

      if (!mounted) return;
      setState(() {
        _todayAttendance = today;
        _historyAttendance = history;
        _allMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _quickCheckIn() async {
    if (_quickCheckInMemberId == null) {
      ErpToast.showError(context, 'Select a member');
      return;
    }

    try {
      await gymService.checkInMember(_quickCheckInMemberId!);
      if (!mounted) return;
      ErpToast.showSuccess(context, 'Checked in!', title: 'Done');
      setState(() => _quickCheckInMemberId = null);
      loadAttendance();
    } catch (e) {
      if (!mounted) return;
      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _checkOut(GymAttendanceModel attendance) async {
    try {
      await gymService.checkOutMember(attendance.id!, memberId: attendance.memberId);
      if (!mounted) return;
      ErpToast.showSuccess(context, 'Checked out!', title: 'Done');
      loadAttendance();
    } catch (e) {
      if (!mounted) return;
      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _selectedTab == 'Today' ? _todayAttendance : _historyAttendance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const HamburgerButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      ),
      body: RefreshIndicator(
        onRefresh: loadAttendance,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Check-In Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2563EB), size: 20),
                        SizedBox(width: 8),
                        Text('Quick Check-In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Dropdown - full width
                    DropdownButtonFormField<int>(
                      value: _quickCheckInMemberId,
                      decoration: InputDecoration(
                        hintText: 'Select member...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2563EB), size: 18),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFBFDBFE))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFBFDBFE))),
                      ),
                      isExpanded: true,
                      items: _allMembers.map((m) {
                        return DropdownMenuItem<int>(
                          value: m.id,
                          child: Text('${m.name} (${m.memberCode})', maxLines: 1, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _quickCheckInMemberId = v),
                    ),
                    const SizedBox(height: 10),
                    // Check-In button - full width
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _quickCheckIn,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Check-In Member'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Tab Pills
              Row(
                children: [
                  _buildTabPill('Today', _todayAttendance.length),
                  const SizedBox(width: 8),
                  _buildTabPill('History', _historyAttendance.length),
                  if (_selectedTab == 'History') ...[
                    const SizedBox(width: 8),
                    _buildDatePill(),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Content
              if (_isLoading)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else if (_error != null)
                _buildErrorBanner()
              else if (displayList.isEmpty)
                _buildEmptyState()
              else
                ...displayList.map((a) => _attendanceCard(a)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attendanceCard(GymAttendanceModel a) {
    final checkInStr = '${a.checkIn.hour.toString().padLeft(2, '0')}:${a.checkIn.minute.toString().padLeft(2, '0')}';
    final checkOutStr = a.checkOut != null
        ? '${a.checkOut!.hour.toString().padLeft(2, '0')}:${a.checkOut!.minute.toString().padLeft(2, '0')}'
        : null;

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
              CircleAvatar(
                radius: 16,
                backgroundColor: a.checkOut == null ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                child: Icon(
                  a.checkOut == null ? Icons.check : Icons.check_circle_outline,
                  color: a.checkOut == null ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.memberName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${a.memberCode ?? '-'} • ${a.attendanceDate.toIso8601String().split('T').first}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                child: Text(a.durationString, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(Icons.login_rounded, 'In: $checkInStr'),
              const SizedBox(width: 6),
              _infoChip(Icons.logout_rounded, checkOutStr != null ? 'Out: $checkOutStr' : 'In gym'),
              const Spacer(),
              if (a.checkOut == null)
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _checkOut(a),
                    child: const Text('Check-Out', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Done', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ),
            ],
          ),
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
      onTap: () => setState(() => _selectedTab = title),
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

  Widget _buildDatePill() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _historyDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _historyDate = picked);
          loadAttendance();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, size: 14, color: Color(0xFF2563EB)),
            const SizedBox(width: 4),
            Text(_historyDate.toIso8601String().split('T').first, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
          TextButton(onPressed: loadAttendance, child: const Text('Retry', style: TextStyle(fontSize: 12))),
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
          Icon(Icons.how_to_reg_rounded, size: 40, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          const Text('No check-ins', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          const Text('Select a member above to check in.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
