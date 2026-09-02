import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'package:erp_software/core/utils/export_print_helper.dart';

class GymReportsScreen extends StatefulWidget {
  const GymReportsScreen({super.key});

  @override
  State<GymReportsScreen> createState() => _GymReportsScreenState();
}

class _GymReportsScreenState extends State<GymReportsScreen> {
  final GymApiService gymService = GymApiService();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  List<Map<String, dynamic>> _memberReport = [];
  List<Map<String, dynamic>> _attendanceReport = [];
  List<Map<String, dynamic>> _revenueReport = [];
  List<Map<String, dynamic>> _expiryReport = [];
  List<Map<String, dynamic>> _trainerReport = [];

  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0;

  final _tabNames = const ['Members', 'Attendance', 'Revenue', 'Expiry', 'Trainers'];

  @override
  void initState() {
    super.initState();
    _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await Future.wait([
      _safeFetch(() => gymService.getMemberReport(startDate: _startDate, endDate: _endDate)),
      _safeFetch(() => gymService.getAttendanceReport(startDate: _startDate, endDate: _endDate)),
      _safeFetch(() => gymService.getRevenueReport(startDate: _startDate, endDate: _endDate)),
      _safeFetch(() => gymService.getExpiryReport()),
      _safeFetch(() => gymService.getTrainerReport()),
    ]);

    final errors = <String>[];
    if (results[0].error != null) errors.add('Members: ${results[0].error}');
    if (results[1].error != null) errors.add('Attendance: ${results[1].error}');
    if (results[2].error != null) errors.add('Revenue: ${results[2].error}');
    if (results[3].error != null) errors.add('Expiry: ${results[3].error}');
    if (results[4].error != null) errors.add('Trainers: ${results[4].error}');

    if (!mounted) return;
    setState(() {
      _memberReport = (results[0].value as List?)?.cast<Map<String, dynamic>>() ?? [];
      _attendanceReport = (results[1].value as List?)?.cast<Map<String, dynamic>>() ?? [];
      _revenueReport = (results[2].value as List?)?.cast<Map<String, dynamic>>() ?? [];
      _expiryReport = (results[3].value as List?)?.cast<Map<String, dynamic>>() ?? [];
      _trainerReport = (results[4].value as List?)?.cast<Map<String, dynamic>>() ?? [];
      _error = errors.isNotEmpty ? errors.join('\n') : null;
      _isLoading = false;
    });
  }

  Future<_ReportResult> _safeFetch(Future<List<Map<String, dynamic>>> Function() fn) async {
    try {
      final data = await fn();
      return _ReportResult(data);
    } catch (e) {
      return _ReportResult([], error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _exportReport() {
    List<Map<String, dynamic>> currentData = [];
    List<Map<String, String>> currentColumns = [];
    String reportTitle = 'Gym_Report';

    switch (_selectedTab) {
      case 0:
        currentData = _memberReport;
        currentColumns = [
          {'key': 'member_code', 'label': 'Code'},
          {'key': 'name', 'label': 'Member Name'},
          {'key': 'phone', 'label': 'Phone'},
          {'key': 'plan_name', 'label': 'Plan'},
          {'key': 'status', 'label': 'Status'},
          {'key': 'total_paid', 'label': 'Total Paid'},
        ];
        reportTitle = 'Gym_Members_Report';
        break;
      case 1:
        currentData = _attendanceReport;
        currentColumns = [
          {'key': 'attendance_date', 'label': 'Date'},
          {'key': 'member_name', 'label': 'Member'},
          {'key': 'check_in', 'label': 'Check-In'},
          {'key': 'check_out', 'label': 'Check-Out'},
          {'key': 'status', 'label': 'Status'},
        ];
        reportTitle = 'Gym_Attendance_Report';
        break;
      case 2:
        currentData = _revenueReport;
        currentColumns = [
          {'key': 'payment_date', 'label': 'Date'},
          {'key': 'reference_number', 'label': 'Ref #'},
          {'key': 'member_name', 'label': 'Member'},
          {'key': 'amount', 'label': 'Amount'},
          {'key': 'payment_method', 'label': 'Method'},
          {'key': 'status', 'label': 'Status'},
        ];
        reportTitle = 'Gym_Revenue_Report';
        break;
      case 3:
        currentData = _expiryReport;
        currentColumns = [
          {'key': 'member_name', 'label': 'Member'},
          {'key': 'plan_name', 'label': 'Plan'},
          {'key': 'start_date', 'label': 'Start'},
          {'key': 'end_date', 'label': 'End'},
          {'key': 'days_remaining', 'label': 'Days Left'},
          {'key': 'status', 'label': 'Status'},
        ];
        reportTitle = 'Gym_Expiry_Report';
        break;
      case 4:
        currentData = _trainerReport;
        currentColumns = [
          {'key': 'trainer_name', 'label': 'Trainer'},
          {'key': 'specialization', 'label': 'Specialization'},
          {'key': 'assigned_members', 'label': 'Assigned'},
          {'key': 'active_members', 'label': 'Active'},
          {'key': 'total_schedules', 'label': 'Schedules'},
        ];
        reportTitle = 'Gym_Trainers_Report';
        break;
    }

    if (currentData.isEmpty) {
      ErpToast.showError(context, 'No data to export.');
      return;
    }

    final headers = currentColumns.map((c) => c['label']!).toList();
    final rows = currentData.map((row) {
      return currentColumns.map((col) {
        final key = col['key']!;
        dynamic val = row[key];
        if (val == null) {
          if (key == 'name') val = row['member_name'];
          if (key == 'status') val = row['member_status'];
          if (key == 'plan_name') val = row['membership_plan'];
          if (key == 'assigned_members') val = row['total_assigned_members'];
          if (key == 'active_members') val = row['active_assignments'];
        }
        if (val == null) return '-';
        if (val is DateTime) return val.toIso8601String().split('T').first;
        return val.toString();
      }).toList();
    }).toList();

    ExportPrintHelper.exportCsv(context: context, filename: reportTitle, headers: headers, rows: rows);
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _getCurrentData();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const HamburgerButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Gym Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.file_download_outlined, size: 22, color: AppColors.primary),
            tooltip: 'Export',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllReports,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range
              _buildDateRange(),
              const SizedBox(height: 14),

              // Section Pills (scrollable)
              _buildSectionPills(),
              const SizedBox(height: 14),

              // Error
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12))),
                    ],
                  ),
                ),

              // Loading
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (currentData.isEmpty)
                _buildEmptyState()
              else
                _buildReportCards(currentData),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCurrentData() {
    switch (_selectedTab) {
      case 0: return _memberReport;
      case 1: return _attendanceReport;
      case 2: return _revenueReport;
      case 3: return _expiryReport;
      case 4: return _trainerReport;
      default: return [];
    }
  }

  Widget _buildDateRange() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.date_range_outlined, color: Color(0xFF2563EB), size: 18),
          const SizedBox(width: 8),
          const Text('Range:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                );
                if (range != null) {
                  setState(() {
                    _startDate = range.start;
                    _endDate = range.end;
                  });
                  _loadAllReports();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '${_startDate.toIso8601String().split("T").first} → ${_endDate.toIso8601String().split("T").first}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF2563EB)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPills() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabNames.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isActive = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? AppColors.primary : const Color(0xFFE2E8F0)),
              ),
              child: Text(
                _tabNames[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          const Text('No data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          const Text('No records found for the selected period.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildReportCards(List<Map<String, dynamic>> data) {
    switch (_selectedTab) {
      case 0: return Column(children: data.map((r) => _memberCard(r)).toList());
      case 1: return Column(children: data.map((r) => _attendanceCard(r)).toList());
      case 2: return Column(children: data.map((r) => _revenueCard(r)).toList());
      case 3: return Column(children: data.map((r) => _expiryCard(r)).toList());
      case 4: return Column(children: data.map((r) => _trainerCard(r)).toList());
      default: return const SizedBox.shrink();
    }
  }

  Widget _memberCard(Map<String, dynamic> r) {
    final name = r['name'] ?? r['member_name'] ?? '-';
    final code = r['member_code'] ?? '';
    final phone = r['phone'] ?? '-';
    final plan = r['plan_name'] ?? r['membership_plan'] ?? '-';
    final status = r['status'] ?? r['member_status'] ?? '-';
    final paid = r['total_paid'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(_initials(name), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('$code • $phone', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoChip(Icons.card_membership_rounded, plan),
              const Spacer(),
              Text('\$$paid', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceCard(Map<String, dynamic> r) {
    final member = r['member_name'] ?? '-';
    final date = _formatDate(r['attendance_date']);
    final checkIn = _formatTime(r['check_in']);
    final checkOut = _formatTime(r['check_out']);
    final status = r['status'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(member, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _infoChip(Icons.calendar_today_rounded, date),
              _infoChip(Icons.login_rounded, 'In: $checkIn'),
              _infoChip(Icons.logout_rounded, 'Out: $checkOut'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _revenueCard(Map<String, dynamic> r) {
    final member = r['member_name'] ?? '-';
    final date = _formatDate(r['payment_date']);
    final amount = r['amount'] ?? 0;
    final method = r['payment_method'] ?? '-';
    final status = r['status'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(member, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('\$$amount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _infoChip(Icons.calendar_today_rounded, date),
              _infoChip(Icons.payment_rounded, method),
              _statusBadge(status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expiryCard(Map<String, dynamic> r) {
    final member = r['member_name'] ?? '-';
    final plan = r['plan_name'] ?? '-';
    final endDate = _formatDate(r['end_date']);
    final daysLeft = r['days_remaining'] ?? '-';
    final status = r['status'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(member, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _infoChip(Icons.card_membership_rounded, plan),
                    _infoChip(Icons.event_busy_rounded, 'End: $endDate'),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _daysColor(daysLeft).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$daysLeft days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _daysColor(daysLeft))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trainerCard(Map<String, dynamic> r) {
    final name = r['trainer_name'] ?? '-';
    final spec = r['specialization'] ?? '-';
    final assigned = r['assigned_members'] ?? r['total_assigned_members'] ?? 0;
    final active = r['active_members'] ?? r['active_assignments'] ?? 0;
    final schedules = r['total_schedules'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                child: Text(_initials(name), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(spec, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _infoChip(Icons.people_rounded, '$assigned assigned'),
              _infoChip(Icons.check_circle_outline, '$active active'),
              _infoChip(Icons.schedule_rounded, '$schedules schedules'),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  String _formatDate(dynamic d) {
    if (d == null || d == '' || d == '-') return '-';
    final str = d.toString();
    if (str.contains('T')) {
      return str.split('T').first;
    }
    return str.split(' ').first;
  }

  String _formatTime(dynamic t) {
    if (t == null || t == '' || t == '-') return '-';
    final str = t.toString();
    if (str.contains('T')) {
      final timePart = str.split('T').last.replaceAll('Z', '');
      final parts = timePart.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $period';
      }
    }
    if (str.contains(':')) {
      final parts = str.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $period';
      }
    }
    return str;
  }

  Widget _statusBadge(String status) {
    final s = status.toUpperCase();
    final isActive = s == 'ACTIVE' || s == 'PAID' || s == 'PRESENT';
    final isInactive = s == 'INACTIVE' || s == 'CANCELLED' || s == 'ABSENT';
    final color = isActive
        ? const Color(0xFF16A34A)
        : isInactive
            ? const Color(0xFFDC2626)
            : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    return 'U';
  }

  Color _daysColor(dynamic days) {
    final d = int.tryParse('$days') ?? 999;
    if (d <= 7) return const Color(0xFFDC2626);
    if (d <= 30) return const Color(0xFFF59E0B);
    return const Color(0xFF16A34A);
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFE2E8F0)),
  );
}

class _ReportResult {
  final List<Map<String, dynamic>> value;
  final String? error;
  _ReportResult(this.value, {this.error});
}
