import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:erp_software/core/models/gym/gym_dashboard_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/gym/add_edit_member_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/add_payment_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/member_details_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/renew_membership_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/payment_receipt_dialog.dart';
import 'package:erp_software/frontend/screens/gym/gym_members_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_attendance_screen.dart';
import 'package:erp_software/frontend/screens/gym/gym_payments_screen.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymDashboardScreen extends StatefulWidget {
  const GymDashboardScreen({super.key});

  @override
  State<GymDashboardScreen> createState() => _GymDashboardScreenState();
}

class _GymDashboardScreenState extends State<GymDashboardScreen> {
  final GymApiService gymService = GymApiService();

  GymDashboardModel? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await gymService.getDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadDashboard,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page Header & Quick Actions
                          _buildPageHeader(context, isMobile),
                          const SizedBox(height: 20),

                          if (_isLoading) ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(60.0),
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            ),
                          ] else if (_error != null) ...[
                            _buildErrorBanner(),
                          ] else if (_dashboard != null) ...[
                            // KPI Metric Cards
                            _buildKpiMetricsRow(isMobile),
                            const SizedBox(height: 24),

                            // Analytics Charts Row
                            _buildChartsSection(isMobile),
                            const SizedBox(height: 24),

                            // Quick Tables: Expiring Soon, Recent Members, Recent Payments
                            _buildRecentTablesSection(isMobile),
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

  Widget _buildPageHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gym Dashboard',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Real-time overview of members, attendance, memberships, and revenue',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            if (!isMobile)
              Row(
                children: [
                  _buildHeaderButton(
                    icon: Icons.person_add_rounded,
                    label: '+ Add Member',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddEditMemberDialog(onSaved: loadDashboard),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderButton(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Check-In',
                    color: const Color(0xFF16A34A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GymAttendanceScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderButton(
                    icon: Icons.payments_rounded,
                    label: 'New Payment',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddPaymentDialog(onSaved: loadDashboard),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHeaderButton(
                  icon: Icons.person_add_rounded,
                  label: '+ Add Member',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddEditMemberDialog(onSaved: loadDashboard),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Check-In',
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GymAttendanceScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.payments_rounded,
                  label: 'New Payment',
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddPaymentDialog(onSaved: loadDashboard),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    Color color = const Color(0xFF2563EB),
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
          ),
          TextButton(
            onPressed: loadDashboard,
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMetricsRow(bool isMobile) {
    final d = _dashboard!;

    final cards = [
      _buildStatCard(
        title: 'TOTAL MEMBERS',
        value: d.totalMembers.toString(),
        subtitle: '${d.activeMembers} currently active',
        icon: Icons.groups_rounded,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymMembersScreen())),
      ),
      _buildStatCard(
        title: 'ACTIVE MEMBERS',
        value: d.activeMembers.toString(),
        subtitle: '${((d.activeMembers / (d.totalMembers > 0 ? d.totalMembers : 1)) * 100).toStringAsFixed(0)}% retention rate',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF16A34A),
        bgColor: const Color(0xFFDCFCE7),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymMembersScreen(initialFilter: 'Active'))),
      ),
      _buildStatCard(
        title: 'EXPIRED MEMBERS',
        value: d.expiredMembers.toString(),
        subtitle: 'Needs membership renewal',
        icon: Icons.cancel_rounded,
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEE2E2),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymMembersScreen(initialFilter: 'Expired'))),
      ),
      _buildStatCard(
        title: 'EXPIRING SOON',
        value: d.expiringSoon.toString(),
        subtitle: 'Expiring in next 7 days',
        icon: Icons.access_time_filled_rounded,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymMembersScreen(initialFilter: 'Expiring Soon'))),
      ),
      _buildStatCard(
        title: "TODAY'S ATTENDANCE",
        value: d.todayAttendance.toString(),
        subtitle: 'Check-ins recorded today',
        icon: Icons.how_to_reg_rounded,
        color: const Color(0xFF0891B2),
        bgColor: const Color(0xFFCFFAFE),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymAttendanceScreen())),
      ),
      _buildStatCard(
        title: "TODAY'S REVENUE",
        value: '\$${d.todayRevenue.toStringAsFixed(2)}',
        subtitle: 'Paid membership fees',
        icon: Icons.payments_rounded,
        color: const Color(0xFF16A34A),
        bgColor: const Color(0xFFDCFCE7),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymPaymentsScreen())),
      ),
      _buildStatCard(
        title: 'PENDING PAYMENTS',
        value: '\$${d.pendingPayments.toStringAsFixed(2)}',
        subtitle: 'Outstanding fee balances',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEE2E2),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymPaymentsScreen(initialStatus: 'PENDING'))),
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: c)).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : 2;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards.map((c) {
            return SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 14) / crossAxisCount,
              child: c,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsSection(bool isMobile) {
    final d = _dashboard!;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile || constraints.maxWidth < 1100) {
          return Column(
            children: [
              _buildRevenueBarChart(d),
              const SizedBox(height: 16),
              _buildAttendanceLineChart(d),
              const SizedBox(height: 16),
              _buildStatusPieChart(d),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildRevenueBarChart(d)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildStatusPieChart(d)),
          ],
        );
      },
    );
  }

  Widget _buildRevenueBarChart(GymDashboardModel d) {
    final revList = d.monthlyRevenueData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Membership Revenue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                child: const Text('Last 6 Months', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: revList.isEmpty
                ? const Center(child: Text('No revenue data yet', style: TextStyle(color: Color(0xFF94A3B8))))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (revList.map((e) => (e['amount'] as num).toDouble()).fold<double>(0, (a, b) => a > b ? a : b) * 1.3).clamp(1000.0, 1000000.0),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${revList[groupIndex]['month']}\n\$${rod.toY.toStringAsFixed(0)}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < revList.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(revList[idx]['month'].toString().split(' ').first, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (val, meta) => Text('\$${val.toInt()}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2000),
                      borderData: FlBorderData(show: false),
                      barGroups: revList.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: (entry.value['amount'] as num).toDouble(),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 22,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceLineChart(GymDashboardModel d) {
    final trend = d.attendanceTrend;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Attendance Flow', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: trend.isEmpty
                ? const Center(child: Text('No attendance recorded this week', style: TextStyle(color: Color(0xFF94A3B8))))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final idx = v.toInt();
                              if (idx >= 0 && idx < trend.length) {
                                return Text(trend[idx]['day'], style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['count'] as num).toDouble())).toList(),
                          isCurved: true,
                          color: const Color(0xFF0891B2),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF0891B2).withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart(GymDashboardModel d) {
    final active = d.activeMembers.toDouble();
    final expired = d.expiredMembers.toDouble();
    final expiringSoon = d.expiringSoon.toDouble();
    final total = active + expired + expiringSoon;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Membership Status Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: total == 0
                ? const Center(child: Text('No members registered yet', style: TextStyle(color: Color(0xFF94A3B8))))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 36,
                      sections: [
                        PieChartSectionData(value: active > 0 ? active : 0.01, color: const Color(0xFF16A34A), title: active.toInt().toString(), radius: 38, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                        PieChartSectionData(value: expiringSoon > 0 ? expiringSoon : 0.01, color: const Color(0xFFD97706), title: expiringSoon.toInt().toString(), radius: 38, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                        PieChartSectionData(value: expired > 0 ? expired : 0.01, color: const Color(0xFFEF4444), title: expired.toInt().toString(), radius: 38, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _buildLegendItem('Active Members', '${active.toInt()}', const Color(0xFF16A34A)),
          const SizedBox(height: 6),
          _buildLegendItem('Expiring in 7 Days', '${expiringSoon.toInt()}', const Color(0xFFD97706)),
          const SizedBox(height: 6),
          _buildLegendItem('Expired Members', '${expired.toInt()}', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildRecentTablesSection(bool isMobile) {
    final d = _dashboard!;

    return Column(
      children: [
        // Expiring Soon Memberships Alert Table
        if (d.expiringMemberships.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
              boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 8),
                        Text('Expiring Memberships (Action Required)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymMembersScreen(initialFilter: 'Expiring Soon'))),
                      child: const Text('View All', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...d.expiringMemberships.map((ms) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${ms.memberName ?? 'Member'} (${ms.memberCode ?? '-'})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                              Text('Plan: ${ms.planName ?? 'Standard'}  •  Expires: ${ms.endDate.toIso8601String().split('T').first}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text('${ms.daysLeft} days left', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => RenewMembershipDialog(membership: ms, onRenewed: loadDashboard),
                            );
                          },
                          child: const Text('Renew', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Recent Members & Recent Payments Row
        LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile || constraints.maxWidth < 1000) {
              return Column(
                children: [
                  _buildRecentMembersCard(d),
                  const SizedBox(height: 16),
                  _buildRecentPaymentsCard(d),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRecentMembersCard(d)),
                const SizedBox(width: 16),
                Expanded(child: _buildRecentPaymentsCard(d)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentMembersCard(GymDashboardModel d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Members', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymMembersScreen())),
                child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (d.recentMembers.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No members registered yet', style: TextStyle(color: Color(0xFF94A3B8)))))
          else
            ...d.recentMembers.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          Text('${m.memberCode}  •  ${m.phone}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                      onPressed: () {
                        if (m.id != null) {
                          showDialog(
                            context: context,
                            builder: (_) => MemberDetailsDialog(memberId: m.id!, onUpdated: loadDashboard),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentsCard(GymDashboardModel d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Payments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymPaymentsScreen())),
                child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (d.recentPayments.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No payments recorded yet', style: TextStyle(color: Color(0xFF94A3B8)))))
          else
            ...d.recentPayments.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.memberName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          Text('${p.paymentDate.toIso8601String().split('T').first}  •  ${p.paymentMethod}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Text('\$${p.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF16A34A))),
                    const SizedBox(width: 8),
                    if (p.id != null)
                      IconButton(
                        icon: const Icon(Icons.print_outlined, size: 18, color: AppColors.primary),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PaymentReceiptDialog(paymentId: p.id!),
                          );
                        },
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
