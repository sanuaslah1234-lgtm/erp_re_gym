import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_attendance_model.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
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
      ErpToast.showError(context, 'Please select a member to check in');
      return;
    }

    try {
      await gymService.checkInMember(_quickCheckInMemberId!);
      if (!mounted) return;
      ErpToast.showSuccess(context, 'Member checked in successfully!', title: 'Check-In Recorded');
      setState(() => _quickCheckInMemberId = null);
      loadAttendance();
    } catch (e) {
      if (!mounted) return;
      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _checkOut(GymAttendanceModel attendance) async {
    try {
      await gymService.checkOutMember(attendance.id!);
      if (!mounted) return;
      ErpToast.showSuccess(context, 'Member checked out successfully!', title: 'Check-Out Complete');
      loadAttendance();
    } catch (e) {
      if (!mounted) return;
      ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 950;
    final displayList = _selectedTab == 'Today' ? _todayAttendance : _historyAttendance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Attendance', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Attendance'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadAttendance,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gym Attendance & Check-In',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2563EB),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Record real-time member check-in/check-out and track workout hours', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Quick Check-In Box
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2563EB), size: 22),
                                    SizedBox(width: 8),
                                    Text('Quick Member Check-In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        initialValue: _quickCheckInMemberId,
                                        decoration: InputDecoration(
                                          hintText: 'Select or scan member to check-in...',
                                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2563EB)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFBFDBFE))),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFBFDBFE))),
                                        ),
                                        items: _allMembers.map((m) {
                                          return DropdownMenuItem<int>(
                                            value: m.id,
                                            child: Text('${m.name} (${m.memberCode} - ${m.phone})'),
                                          );
                                        }).toList(),
                                        onChanged: (v) => setState(() => _quickCheckInMemberId = v),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: _quickCheckIn,
                                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                                      label: const Text('Check-In Member'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF16A34A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tab Filter & Date Picker Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildTabPill('Today', _todayAttendance.length),
                                  const SizedBox(width: 8),
                                  _buildTabPill('History', _historyAttendance.length),
                                ],
                              ),
                              if (_selectedTab == 'History')
                                InkWell(
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
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_month, size: 16, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 8),
                                        Text(_historyDate.toIso8601String().split('T').first, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_isLoading) ...[
                            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primary)))
                          ] else if (_error != null) ...[
                            _buildErrorBanner(),
                          ] else if (displayList.isEmpty) ...[
                            _buildEmptyState(),
                          ] else ...[
                            _buildAttendanceList(displayList, isMobile),
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
      onTap: () => setState(() => _selectedTab = title),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
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
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
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
          TextButton(onPressed: loadAttendance, child: const Text('Retry')),
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
            child: const Icon(Icons.how_to_reg_rounded, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('No check-ins recorded', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Select a member from the quick check-in box above to log attendance.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(List<GymAttendanceModel> list, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final a = list[index];
          final checkInStr = '${a.checkIn.hour.toString().padLeft(2, '0')}:${a.checkIn.minute.toString().padLeft(2, '0')}';
          final checkOutStr = a.checkOut != null
              ? '${a.checkOut!.hour.toString().padLeft(2, '0')}:${a.checkOut!.minute.toString().padLeft(2, '0')}'
              : null;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: const Icon(Icons.check, color: Color(0xFF16A34A), size: 20),
                ),
                const SizedBox(width: 14),

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.memberName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('Code: ${a.memberCode ?? '-'}  •  Date: ${a.attendanceDate.toIso8601String().split('T').first}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),

                if (!isMobile) ...[
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check-in: $checkInStr', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(
                          checkOutStr != null ? 'Check-out: $checkOutStr' : 'Currently in gym',
                          style: TextStyle(fontSize: 11, color: checkOutStr != null ? const Color(0xFF64748B) : const Color(0xFF16A34A), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                  child: Text(a.durationString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                ),
                const SizedBox(width: 12),

                if (a.checkOut == null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _checkOut(a),
                    child: const Text('Check-Out', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Completed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
