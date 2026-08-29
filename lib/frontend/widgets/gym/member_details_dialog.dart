import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/core/models/gym/gym_attendance_model.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/core/models/gym/gym_workout_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/theme/app_colors.dart';
import 'renew_membership_dialog.dart';
import 'payment_receipt_dialog.dart';

class MemberDetailsDialog extends StatefulWidget {
  final int memberId;
  final VoidCallback onUpdated;

  const MemberDetailsDialog({
    super.key,
    required this.memberId,
    required this.onUpdated,
  });

  @override
  State<MemberDetailsDialog> createState() => _MemberDetailsDialogState();
}

class _MemberDetailsDialogState extends State<MemberDetailsDialog> with SingleTickerProviderStateMixin {
  final GymApiService gymService = GymApiService();
  late TabController _tabController;

  GymMemberModel? _member;
  List<GymMembershipModel> _memberships = [];
  List<GymAttendanceModel> _attendance = [];
  List<GymPaymentModel> _payments = [];
  List<WorkoutPlanModel> _workouts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMemberData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberData() async {
    setState(() => _isLoading = true);
    try {
      final member = await gymService.getMemberById(widget.memberId);
      final memberships = await gymService.getMemberMembership(widget.memberId);
      final attendance = await gymService.getMemberAttendance(widget.memberId);
      final payments = await gymService.getMemberPayments(widget.memberId);
      final workouts = await gymService.getMemberWorkouts(widget.memberId);

      if (!mounted) return;
      setState(() {
        _member = member;
        _memberships = memberships;
        _attendance = attendance;
        _payments = payments;
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: 800,
        height: 650,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _member != null && _member!.name.isNotEmpty ? _member!.name[0].toUpperCase() : 'M',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _member?.name ?? 'Loading Member...',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusBadge(_member?.status ?? 'ACTIVE'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${_member?.memberCode ?? '-'}  •  Phone: ${_member?.phone ?? '-'}  •  Email: ${_member?.email ?? 'N/A'}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
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

            // Tab Bar
            Container(
              color: const Color(0xFFF8FAFC),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: 'Memberships (${_memberships.length})'),
                  Tab(text: 'Attendance (${_attendance.length})'),
                  Tab(text: 'Payments (${_payments.length})'),
                  Tab(text: 'Workouts (${_workouts.length})'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMembershipsTab(),
                        _buildAttendanceTab(),
                        _buildPaymentsTab(),
                        _buildWorkoutsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipsTab() {
    if (_memberships.isEmpty) {
      return _buildEmptyState('No membership records found', Icons.card_membership_outlined);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _memberships.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ms = _memberships[index];
        final isLatest = index == 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLatest ? const Color(0xFFF0FDF4) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isLatest ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLatest ? AppColors.successLight : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fitness_center_rounded, color: isLatest ? AppColors.success : const Color(0xFF64748B), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ms.planName ?? 'Standard Plan',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(ms.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Period: ${ms.startDate.toIso8601String().split('T').first}  to  ${ms.endDate.toIso8601String().split('T').first} (${ms.daysLeft} days left)',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${ms.finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  if (ms.id != null)
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => RenewMembershipDialog(
                            membership: ms,
                            onRenewed: () {
                              _loadMemberData();
                              widget.onUpdated();
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.autorenew_rounded, size: 16, color: AppColors.primary),
                      label: const Text('Renew', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    if (_attendance.isEmpty) {
      return _buildEmptyState('No attendance check-ins logged yet', Icons.access_time_outlined);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _attendance.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = _attendance[index];
        final checkInStr = '${a.checkIn.hour.toString().padLeft(2, '0')}:${a.checkIn.minute.toString().padLeft(2, '0')}';
        final checkOutStr = a.checkOut != null
            ? '${a.checkOut!.hour.toString().padLeft(2, '0')}:${a.checkOut!.minute.toString().padLeft(2, '0')}'
            : 'In Progress';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Text(
                a.attendanceDate.toIso8601String().split('T').first,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 20),
              Text('Check-in: $checkInStr', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(width: 14),
              Text('Check-out: $checkOutStr', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                child: Text(a.durationString, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) {
      return _buildEmptyState('No payment transactions found', Icons.payments_outlined);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _payments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = _payments[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ref: ${p.referenceNumber ?? 'PAY-${p.id}'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    Text('Date: ${p.paymentDate.toIso8601String().split('T').first}  •  Method: ${p.paymentMethod}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Text(
                '\$${p.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 10),
              _buildStatusBadge(p.status),
              const SizedBox(width: 8),
              if (p.id != null)
                IconButton(
                  icon: const Icon(Icons.print_outlined, size: 18, color: AppColors.primary),
                  tooltip: 'View Receipt',
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
      },
    );
  }

  Widget _buildWorkoutsTab() {
    if (_workouts.isEmpty) {
      return _buildEmptyState('No customized workout plans assigned yet', Icons.sports_gymnastics_rounded);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _workouts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final w = _workouts[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(w.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(width: 10),
                  _buildStatusBadge(w.status),
                  const Spacer(),
                  if (w.goal != null)
                    Chip(
                      label: Text('Goal: ${w.goal!}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              if (w.exercises.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Assigned Exercises:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                ...w.exercises.map((ex) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 18, color: AppColors.primary),
                          Text('${ex.exerciseName} (${ex.muscleGroup ?? "General"})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('${ex.sets} sets × ${ex.reps} reps', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    )),
              ],
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
      case 'ACTIVE':
      case 'PAID':
      case 'PRESENT':
        bg = AppColors.successLight;
        text = AppColors.successText;
        break;
      case 'EXPIRED':
      case 'CANCELLED':
      case 'REFUNDED':
        bg = AppColors.dangerLight;
        text = AppColors.dangerText;
        break;
      case 'PENDING':
      case 'PARTIAL':
        bg = AppColors.warningLight;
        text = AppColors.warningText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(msg, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
