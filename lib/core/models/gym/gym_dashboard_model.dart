import 'gym_member_model.dart';
import 'gym_membership_model.dart';
import 'gym_payment_model.dart';

class GymDashboardModel {
  final int totalMembers;
  final int activeMembers;
  final int expiredMembers;
  final int expiringSoon;
  final int todayAttendance;
  final double todayRevenue;
  final double pendingPayments;
  final List<GymMemberModel> recentMembers;
  final List<GymPaymentModel> recentPayments;
  final List<GymMembershipModel> expiringMemberships;
  final List<Map<String, dynamic>> monthlyRevenueData;
  final List<Map<String, dynamic>> attendanceTrend;
  final Map<String, int> statusBreakdown;

  GymDashboardModel({
    this.totalMembers = 0,
    this.activeMembers = 0,
    this.expiredMembers = 0,
    this.expiringSoon = 0,
    this.todayAttendance = 0,
    this.todayRevenue = 0.0,
    this.pendingPayments = 0.0,
    this.recentMembers = const [],
    this.recentPayments = const [],
    this.expiringMemberships = const [],
    this.monthlyRevenueData = const [],
    this.attendanceTrend = const [],
    this.statusBreakdown = const {},
  });

  factory GymDashboardModel.fromMap(Map<String, dynamic> map) {
    final rawRecentM = map['recentMembers'] ?? map['recent_members'];
    final rawRecentP = map['recentPayments'] ?? map['recent_payments'];
    final rawExpiringM = map['expiringMemberships'] ?? map['expiring_memberships'];
    final rawMonthlyRev = map['monthlyRevenueData'] ?? map['monthly_revenue_data'];
    final rawTrend = map['attendanceTrend'] ?? map['attendance_trend'];
    final rawBreakdown = map['statusBreakdown'] ?? map['status_breakdown'];

    List<GymMemberModel> members = [];
    if (rawRecentM is List) {
      members = rawRecentM.map((m) => GymMemberModel.fromMap(m as Map<String, dynamic>)).toList();
    }

    List<GymPaymentModel> payments = [];
    if (rawRecentP is List) {
      payments = rawRecentP.map((p) => GymPaymentModel.fromMap(p as Map<String, dynamic>)).toList();
    }

    List<GymMembershipModel> expiring = [];
    if (rawExpiringM is List) {
      expiring = rawExpiringM.map((em) => GymMembershipModel.fromMap(em as Map<String, dynamic>)).toList();
    }

    List<Map<String, dynamic>> monthlyRev = [];
    if (rawMonthlyRev is List) {
      monthlyRev = rawMonthlyRev.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    List<Map<String, dynamic>> trend = [];
    if (rawTrend is List) {
      trend = rawTrend.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    Map<String, int> breakdown = {};
    if (rawBreakdown is Map) {
      rawBreakdown.forEach((k, v) {
        breakdown[k.toString()] = int.tryParse(v.toString()) ?? 0;
      });
    }

    return GymDashboardModel(
      totalMembers: int.tryParse(map['totalMembers']?.toString() ?? map['total_members']?.toString() ?? '0') ?? 0,
      activeMembers: int.tryParse(map['activeMembers']?.toString() ?? map['active_members']?.toString() ?? '0') ?? 0,
      expiredMembers: int.tryParse(map['expiredMembers']?.toString() ?? map['expired_members']?.toString() ?? '0') ?? 0,
      expiringSoon: int.tryParse(map['expiringSoon']?.toString() ?? map['expiring_soon']?.toString() ?? '0') ?? 0,
      todayAttendance: int.tryParse(map['todayAttendance']?.toString() ?? map['today_attendance']?.toString() ?? '0') ?? 0,
      todayRevenue: double.tryParse(map['todayRevenue']?.toString() ?? map['today_revenue']?.toString() ?? '0') ?? 0.0,
      pendingPayments: double.tryParse(map['pendingPayments']?.toString() ?? map['pending_payments']?.toString() ?? '0') ?? 0.0,
      recentMembers: members,
      recentPayments: payments,
      expiringMemberships: expiring,
      monthlyRevenueData: monthlyRev,
      attendanceTrend: trend,
      statusBreakdown: breakdown,
    );
  }

  factory GymDashboardModel.fromJson(Map<String, dynamic> json) => GymDashboardModel.fromMap(json);

  Map<String, dynamic> toJson() {
    return {
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'expiredMembers': expiredMembers,
      'expiringSoon': expiringSoon,
      'todayAttendance': todayAttendance,
      'todayRevenue': todayRevenue,
      'pendingPayments': pendingPayments,
      'recentMembers': recentMembers.map((m) => m.toJson()).toList(),
      'recentPayments': recentPayments.map((p) => p.toJson()).toList(),
      'expiringMemberships': expiringMemberships.map((em) => em.toJson()).toList(),
      'monthlyRevenueData': monthlyRevenueData,
      'attendanceTrend': attendanceTrend,
      'statusBreakdown': statusBreakdown,
    };
  }
}
