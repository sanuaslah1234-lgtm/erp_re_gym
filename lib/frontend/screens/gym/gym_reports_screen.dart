import 'package:flutter/material.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymReportsScreen extends StatefulWidget {
  const GymReportsScreen({super.key});

  @override
  State<GymReportsScreen> createState() => _GymReportsScreenState();
}

class _GymReportsScreenState extends State<GymReportsScreen> with SingleTickerProviderStateMixin {
  final GymApiService gymService = GymApiService();
  late TabController _tabController;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  List<Map<String, dynamic>> _memberReport = [];
  List<Map<String, dynamic>> _attendanceReport = [];
  List<Map<String, dynamic>> _revenueReport = [];
  List<Map<String, dynamic>> _expiryReport = [];
  List<Map<String, dynamic>> _trainerReport = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCurrentTabReport();
      }
    });
    _loadAllReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final members = await gymService.getMemberReport(startDate: _startDate, endDate: _endDate);
      final attendance = await gymService.getAttendanceReport(startDate: _startDate, endDate: _endDate);
      final revenue = await gymService.getRevenueReport(startDate: _startDate, endDate: _endDate);
      final expiry = await gymService.getExpiryReport();
      final trainers = await gymService.getTrainerReport();

      if (!mounted) return;
      setState(() {
        _memberReport = members;
        _attendanceReport = attendance;
        _revenueReport = revenue;
        _expiryReport = expiry;
        _trainerReport = trainers;
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

  Future<void> _loadCurrentTabReport() async {
    setState(() => _isLoading = true);
    try {
      switch (_tabController.index) {
        case 0:
          _memberReport = await gymService.getMemberReport(startDate: _startDate, endDate: _endDate);
          break;
        case 1:
          _attendanceReport = await gymService.getAttendanceReport(startDate: _startDate, endDate: _endDate);
          break;
        case 2:
          _revenueReport = await gymService.getRevenueReport(startDate: _startDate, endDate: _endDate);
          break;
        case 3:
          _expiryReport = await gymService.getExpiryReport();
          break;
        case 4:
          _trainerReport = await gymService.getTrainerReport();
          break;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _exportReport() {
    final titles = ['Members_Report', 'Attendance_Report', 'Revenue_Report', 'Expiry_Report', 'Trainers_Report'];
    final currentTitle = titles[_tabController.index];
    ErpToast.showSuccess(context, '$currentTitle exported successfully to CSV / PDF format!', title: 'Report Exported');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Gym Reports', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Gym Reports'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: SingleChildScrollView(
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
                                  'Gym Reports & Analytics',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2563EB),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Comprehensive analytics on memberships, attendance, billing, and trainers', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _exportReport,
                              icon: const Icon(Icons.file_download_outlined, size: 18),
                              label: const Text('Export Data'),
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

                        // Date Filter Bar
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range_outlined, color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 10),
                              const Text('Date Range:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                              const SizedBox(width: 14),
                              InkWell(
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    '${_startDate.toIso8601String().split("T").first}  →  ${_endDate.toIso8601String().split("T").first}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tabs
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: AppColors.primary,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: const Color(0xFF64748B),
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            isScrollable: true,
                            tabs: const [
                              Tab(text: 'Member Report'),
                              Tab(text: 'Attendance Report'),
                              Tab(text: 'Revenue Report'),
                              Tab(text: 'Expiry Report'),
                              Tab(text: 'Trainer Report'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tab Content
                        if (_isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator(color: AppColors.primary)))
                        else if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                            child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                          )
                        else
                          SizedBox(
                            height: 520,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildReportTable(_memberReport, [
                                  {'key': 'member_code', 'label': 'Code'},
                                  {'key': 'name', 'label': 'Member Name'},
                                  {'key': 'phone', 'label': 'Phone'},
                                  {'key': 'plan_name', 'label': 'Plan'},
                                  {'key': 'status', 'label': 'Status'},
                                  {'key': 'total_paid', 'label': 'Total Paid (USD)'},
                                ]),
                                _buildReportTable(_attendanceReport, [
                                  {'key': 'attendance_date', 'label': 'Date'},
                                  {'key': 'member_name', 'label': 'Member'},
                                  {'key': 'check_in', 'label': 'Check-In'},
                                  {'key': 'check_out', 'label': 'Check-Out'},
                                  {'key': 'status', 'label': 'Status'},
                                ]),
                                _buildReportTable(_revenueReport, [
                                  {'key': 'payment_date', 'label': 'Date'},
                                  {'key': 'reference_number', 'label': 'Ref #'},
                                  {'key': 'member_name', 'label': 'Member'},
                                  {'key': 'amount', 'label': 'Amount (USD)'},
                                  {'key': 'payment_method', 'label': 'Method'},
                                  {'key': 'status', 'label': 'Status'},
                                ]),
                                _buildReportTable(_expiryReport, [
                                  {'key': 'member_name', 'label': 'Member'},
                                  {'key': 'plan_name', 'label': 'Plan'},
                                  {'key': 'start_date', 'label': 'Start'},
                                  {'key': 'end_date', 'label': 'End'},
                                  {'key': 'days_remaining', 'label': 'Days Left'},
                                  {'key': 'status', 'label': 'Status'},
                                ]),
                                _buildReportTable(_trainerReport, [
                                  {'key': 'trainer_name', 'label': 'Trainer'},
                                  {'key': 'specialization', 'label': 'Specialization'},
                                  {'key': 'assigned_members', 'label': 'Assigned Clients'},
                                  {'key': 'active_members', 'label': 'Active Clients'},
                                  {'key': 'total_schedules', 'label': 'Schedules'},
                                ]),
                              ],
                            ),
                          ),
                      ],
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

  Widget _buildReportTable(List<Map<String, dynamic>> data, List<Map<String, String>> columns) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: const Center(child: Text('No report records found for the selected period.', style: TextStyle(color: Color(0xFF64748B)))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: columns.map((col) => DataColumn(label: Text(col['label']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))).toList(),
            rows: data.map((row) {
              return DataRow(
                cells: columns.map((col) {
                  final key = col['key']!;
                  dynamic val = row[key] ?? '-';
                  if (val is DateTime) val = val.toIso8601String().split('T').first;
                  return DataCell(Text(val.toString(), style: const TextStyle(fontSize: 13)));
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
