import 'package:postgres/postgres.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/gym/gym_attendance_model.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/core/models/gym/gym_workout_model.dart';
import 'package:erp_software/core/models/gym/gym_schedule_model.dart';
import 'package:erp_software/core/models/gym/gym_dashboard_model.dart';

class GymService {
  final PostgresService postgresService;

  GymService(this.postgresService);

  Connection get _conn => postgresService.connection;

  // ===========================================================================
  // 1. DASHBOARD ANALYTICS & STATS
  // ===========================================================================
  Future<GymDashboardModel> getDashboardSummary() async {
    // 1. Total & Active Members
    final memberStatsRes = await _conn.execute('''
      SELECT 
        COUNT(*)::int AS total_members,
        COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END)::int AS active_members,
        COUNT(CASE WHEN status = 'EXPIRED' THEN 1 END)::int AS expired_members
      FROM gym_members
    ''');
    final mRow = memberStatsRes.first.toColumnMap();
    final totalMembers = int.tryParse(mRow['total_members']?.toString() ?? '0') ?? 0;
    final activeMembers = int.tryParse(mRow['active_members']?.toString() ?? '0') ?? 0;
    final expiredMembers = int.tryParse(mRow['expired_members']?.toString() ?? '0') ?? 0;

    // 2. Expiring Soon (Next 7 days)
    final expiringSoonRes = await _conn.execute('''
      SELECT COUNT(*)::int AS expiring_soon
      FROM gym_memberships
      WHERE status = 'ACTIVE' 
        AND end_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '7 days')
    ''');
    final expiringSoon = int.tryParse(expiringSoonRes.first.toColumnMap()['expiring_soon']?.toString() ?? '0') ?? 0;

    // 3. Today Attendance
    final todayAttRes = await _conn.execute('''
      SELECT COUNT(*)::int AS today_attendance
      FROM gym_attendance
      WHERE attendance_date = CURRENT_DATE
    ''');
    final todayAttendance = int.tryParse(todayAttRes.first.toColumnMap()['today_attendance']?.toString() ?? '0') ?? 0;

    // 4. Today Revenue & Pending Payments
    final revRes = await _conn.execute('''
      SELECT 
        COALESCE(SUM(CASE WHEN payment_date::date = CURRENT_DATE AND status = 'PAID' THEN amount ELSE 0 END), 0)::numeric AS today_revenue,
        COALESCE(SUM(CASE WHEN status = 'PENDING' THEN amount ELSE 0 END), 0)::numeric AS pending_payments
      FROM gym_payments
    ''');
    final revRow = revRes.first.toColumnMap();
    final todayRevenue = double.tryParse(revRow['today_revenue']?.toString() ?? '0') ?? 0.0;
    final pendingPayments = double.tryParse(revRow['pending_payments']?.toString() ?? '0') ?? 0.0;

    // 5. Recent 5 Members
    final recentMembers = await getMembers(limit: 5);

    // 6. Recent 5 Payments
    final recentPayments = await getPayments(limit: 5);

    // 7. Expiring Memberships (within 7 days)
    final expiringMemberships = await getMemberships(expiringSoon: true, limit: 5);

    // 8. Monthly Revenue Breakdown (Last 6 months)
    final monthlyRevRes = await _conn.execute('''
      SELECT 
        TO_CHAR(payment_date, 'Mon YYYY') AS month_label,
        TO_CHAR(payment_date, 'YYYY-MM') AS month_key,
        COALESCE(SUM(amount), 0)::numeric AS total_amount
      FROM gym_payments
      WHERE status = 'PAID' AND payment_date >= CURRENT_DATE - INTERVAL '6 months'
      GROUP BY TO_CHAR(payment_date, 'Mon YYYY'), TO_CHAR(payment_date, 'YYYY-MM')
      ORDER BY month_key ASC
    ''');
    final monthlyRevenueData = monthlyRevRes.map((r) {
      final col = r.toColumnMap();
      return {
        'month': col['month_label']?.toString() ?? '',
        'amount': double.tryParse(col['total_amount']?.toString() ?? '0') ?? 0.0,
      };
    }).toList();

    // 9. Attendance Trend (Last 7 days)
    final attTrendRes = await _conn.execute('''
      SELECT 
        TO_CHAR(attendance_date, 'Dy') AS day_label,
        attendance_date,
        COUNT(*)::int AS check_ins
      FROM gym_attendance
      WHERE attendance_date >= CURRENT_DATE - INTERVAL '6 days'
      GROUP BY attendance_date, TO_CHAR(attendance_date, 'Dy')
      ORDER BY attendance_date ASC
    ''');
    final attendanceTrend = attTrendRes.map((r) {
      final col = r.toColumnMap();
      return {
        'day': col['day_label']?.toString() ?? '',
        'date': col['attendance_date']?.toString().split('T').first ?? '',
        'count': int.tryParse(col['check_ins']?.toString() ?? '0') ?? 0,
      };
    }).toList();

    // 10. Status Breakdown
    final statusBreakdown = {
      'Active': activeMembers,
      'Expired': expiredMembers,
      'Expiring Soon': expiringSoon,
      'Inactive': (totalMembers - activeMembers - expiredMembers).clamp(0, 99999),
    };

    return GymDashboardModel(
      totalMembers: totalMembers,
      activeMembers: activeMembers,
      expiredMembers: expiredMembers,
      expiringSoon: expiringSoon,
      todayAttendance: todayAttendance,
      todayRevenue: todayRevenue,
      pendingPayments: pendingPayments,
      recentMembers: recentMembers,
      recentPayments: recentPayments,
      expiringMemberships: expiringMemberships,
      monthlyRevenueData: monthlyRevenueData,
      attendanceTrend: attendanceTrend,
      statusBreakdown: statusBreakdown,
    );
  }

  // ===========================================================================
  // 2. MEMBERS MANAGEMENT
  // ===========================================================================
  Future<List<GymMemberModel>> getMembers({
    String? status,
    String? search,
    bool? expiringSoon,
    int? limit,
  }) async {
    String query = '''
      SELECT 
        m.*,
        p.name AS current_plan_name,
        ms.end_date AS current_membership_end_date,
        (ms.end_date - CURRENT_DATE) AS days_remaining,
        t.name AS assigned_trainer_name,
        t.id AS assigned_trainer_id,
        COALESCE(pay.total_paid, 0)::numeric AS total_paid,
        COALESCE(att.att_count, 0)::int AS total_attendance_count
      FROM gym_members m
      LEFT JOIN LATERAL (
        SELECT ms_inner.plan_id, ms_inner.end_date, ms_inner.status
        FROM gym_memberships ms_inner
        WHERE ms_inner.member_id = m.id
        ORDER BY ms_inner.end_date DESC
        LIMIT 1
      ) ms ON true
      LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
      LEFT JOIN LATERAL (
        SELECT tr.id, tr.name
        FROM gym_trainer_assignments ta
        JOIN gym_trainers tr ON ta.trainer_id = tr.id
        WHERE ta.member_id = m.id AND ta.status = 'ACTIVE'
        ORDER BY ta.created_at DESC
        LIMIT 1
      ) t ON true
      LEFT JOIN (
        SELECT member_id, SUM(amount) AS total_paid
        FROM gym_payments
        WHERE status = 'PAID'
        GROUP BY member_id
      ) pay ON pay.member_id = m.id
      LEFT JOIN (
        SELECT member_id, COUNT(*) AS att_count
        FROM gym_attendance
        GROUP BY member_id
      ) att ON att.member_id = m.id
      WHERE 1=1
    ''';

    final Map<String, dynamic> params = {};

    if (status != null && status.isNotEmpty && status != 'ALL') {
      query += ' AND m.status = @status';
      params['status'] = status.toUpperCase();
    }

    if (expiringSoon == true) {
      query += " AND ms.status = 'ACTIVE' AND ms.end_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '7 days')";
    }

    if (search != null && search.trim().isNotEmpty) {
      query += ''' AND (
        LOWER(m.name) LIKE @search OR
        LOWER(m.member_code) LIKE @search OR
        LOWER(m.phone) LIKE @search OR
        LOWER(COALESCE(m.email, '')) LIKE @search
      )''';
      params['search'] = '%${search.trim().toLowerCase()}%';
    }

    query += ' ORDER BY m.created_at DESC';

    if (limit != null && limit > 0) {
      query += ' LIMIT $limit';
    }

    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => GymMemberModel.fromMap(r.toColumnMap())).toList();
  }

  Future<GymMemberModel?> getMemberById(int id) async {
    final list = await _conn.execute(
      Sql.named('''
        SELECT 
          m.*,
          p.name AS current_plan_name,
          ms.end_date AS current_membership_end_date,
          (ms.end_date - CURRENT_DATE) AS days_remaining,
          t.name AS assigned_trainer_name,
          t.id AS assigned_trainer_id,
          COALESCE(pay.total_paid, 0)::numeric AS total_paid,
          COALESCE(att.att_count, 0)::int AS total_attendance_count
        FROM gym_members m
        LEFT JOIN LATERAL (
          SELECT ms_inner.plan_id, ms_inner.end_date, ms_inner.status
          FROM gym_memberships ms_inner
          WHERE ms_inner.member_id = m.id
          ORDER BY ms_inner.end_date DESC
          LIMIT 1
        ) ms ON true
        LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
        LEFT JOIN LATERAL (
          SELECT tr.id, tr.name
          FROM gym_trainer_assignments ta
          JOIN gym_trainers tr ON ta.trainer_id = tr.id
          WHERE ta.member_id = m.id AND ta.status = 'ACTIVE'
          ORDER BY ta.created_at DESC
          LIMIT 1
        ) t ON true
        LEFT JOIN (
          SELECT member_id, SUM(amount) AS total_paid
          FROM gym_payments
          WHERE status = 'PAID'
          GROUP BY member_id
        ) pay ON pay.member_id = m.id
        LEFT JOIN (
          SELECT member_id, COUNT(*) AS att_count
          FROM gym_attendance
          GROUP BY member_id
        ) att ON att.member_id = m.id
        WHERE m.id = @id
      '''),
      parameters: {'id': id},
    );

    if (list.isEmpty) return null;
    return GymMemberModel.fromMap(list.first.toColumnMap());
  }

  Future<GymMemberModel> createMember(
    GymMemberModel member, {
    int? planId,
    double? paidAmount,
    String? paymentMethod,
    int? trainerId,
  }) async {
    String memberCode = member.memberCode.trim();
    if (memberCode.isEmpty) {
      final countRes = await _conn.execute('SELECT nextval(pg_get_serial_sequence(\'gym_members\', \'id\')) as seq');
      final seq = countRes.first.toColumnMap()['seq'] ?? DateTime.now().millisecondsSinceEpoch % 10000;
      memberCode = 'GYM-${1000 + int.parse(seq.toString())}';
    }

    // Auto create customer in ERP if not linked
    String? customerId = member.customerId;
    if (customerId == null) {
      final custCheck = await _conn.execute(
        Sql.named('SELECT id FROM customers WHERE phone = @phone LIMIT 1'),
        parameters: {'phone': member.phone},
      );
      if (custCheck.isNotEmpty) {
        customerId = custCheck.first.toColumnMap()['id']?.toString();
      } else {
        final custInsert = await _conn.execute(
          Sql.named('''
            INSERT INTO customers (name, phone, email, address, loyalty_id)
            VALUES (@name, @phone, @email, @address, @loyalty_id)
            RETURNING id
          '''),
          parameters: {
            'name': member.name,
            'phone': member.phone,
            'email': member.email,
            'address': member.address,
            'loyalty_id': memberCode,
          },
        );
        customerId = custInsert.first.toColumnMap()['id']?.toString();
      }
    }

    final insertRes = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_members (
          member_code, customer_id, name, phone, email, gender, 
          date_of_birth, address, emergency_contact, join_date, status, photo
        )
        VALUES (
          @member_code, @customer_id, @name, @phone, @email, @gender,
          @date_of_birth, @address, @emergency_contact, @join_date, @status, @photo
        )
        RETURNING *
      '''),
      parameters: {
        'member_code': memberCode,
        'customer_id': customerId,
        'name': member.name,
        'phone': member.phone,
        'email': member.email,
        'gender': member.gender,
        'date_of_birth': member.dateOfBirth?.toIso8601String().split('T').first,
        'address': member.address,
        'emergency_contact': member.emergencyContact,
        'join_date': member.joinDate.toIso8601String().split('T').first,
        'status': member.status,
        'photo': member.photo,
      },
    );

    final createdMember = GymMemberModel.fromMap(insertRes.first.toColumnMap());

    // Optional plan assignment
    if (planId != null && planId > 0) {
      final plan = await getPlanById(planId);
      if (plan != null) {
        final startDate = DateTime.now();
        final endDate = startDate.add(Duration(days: plan.durationDays));
        final membership = GymMembershipModel(
          memberId: createdMember.id!,
          planId: plan.id!,
          startDate: startDate,
          endDate: endDate,
          amount: plan.price,
          discount: plan.discount,
          tax: plan.tax,
          finalAmount: plan.totalAmount,
          status: 'ACTIVE',
        );
        await createMembership(
          membership,
          paidAmount: paidAmount ?? plan.totalAmount,
          paymentMethod: paymentMethod ?? 'CASH',
        );
      }
    }

    // Optional trainer assignment
    if (trainerId != null && trainerId > 0) {
      await assignMemberToTrainer(createdMember.id!, trainerId);
    }

    return (await getMemberById(createdMember.id!)) ?? createdMember;
  }

  Future<GymMemberModel?> updateMember(int id, GymMemberModel member) async {
    final result = await _conn.execute(
      Sql.named('''
        UPDATE gym_members
        SET
          name = @name,
          phone = @phone,
          email = @email,
          gender = @gender,
          date_of_birth = @date_of_birth,
          address = @address,
          emergency_contact = @emergency_contact,
          status = @status,
          photo = @photo,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'name': member.name,
        'phone': member.phone,
        'email': member.email,
        'gender': member.gender,
        'date_of_birth': member.dateOfBirth?.toIso8601String().split('T').first,
        'address': member.address,
        'emergency_contact': member.emergencyContact,
        'status': member.status,
        'photo': member.photo,
      },
    );

    if (result.isEmpty) return null;
    return getMemberById(id);
  }

  Future<bool> deleteMember(int id) async {
    final result = await _conn.execute(
      Sql.named('DELETE FROM gym_members WHERE id = @id'),
      parameters: {'id': id},
    );
    return result.affectedRows > 0;
  }

  // ===========================================================================
  // 3. MEMBERSHIP PLANS
  // ===========================================================================
  Future<List<GymPlanModel>> getPlans({String? status}) async {
    String query = 'SELECT * FROM gym_membership_plans WHERE 1=1';
    final Map<String, dynamic> params = {};

    if (status != null && status.isNotEmpty && status != 'ALL') {
      query += ' AND status = @status';
      params['status'] = status.toUpperCase();
    }

    query += ' ORDER BY duration_days ASC';
    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => GymPlanModel.fromMap(r.toColumnMap())).toList();
  }

  Future<GymPlanModel?> getPlanById(int id) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM gym_membership_plans WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return GymPlanModel.fromMap(result.first.toColumnMap());
  }

  Future<GymPlanModel> createPlan(GymPlanModel plan) async {
    final total = (plan.price - plan.discount + plan.tax).clamp(0.0, 9999999.0);
    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_membership_plans (
          name, description, duration_days, price, discount, tax, total_amount, status
        )
        VALUES (
          @name, @description, @duration_days, @price, @discount, @tax, @total_amount, @status
        )
        RETURNING *
      '''),
      parameters: {
        'name': plan.name,
        'description': plan.description,
        'duration_days': plan.durationDays,
        'price': plan.price,
        'discount': plan.discount,
        'tax': plan.tax,
        'total_amount': total,
        'status': plan.status,
      },
    );
    return GymPlanModel.fromMap(result.first.toColumnMap());
  }

  Future<GymPlanModel?> updatePlan(int id, GymPlanModel plan) async {
    final total = (plan.price - plan.discount + plan.tax).clamp(0.0, 9999999.0);
    final result = await _conn.execute(
      Sql.named('''
        UPDATE gym_membership_plans
        SET
          name = @name,
          description = @description,
          duration_days = @duration_days,
          price = @price,
          discount = @discount,
          tax = @tax,
          total_amount = @total_amount,
          status = @status,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'name': plan.name,
        'description': plan.description,
        'duration_days': plan.durationDays,
        'price': plan.price,
        'discount': plan.discount,
        'tax': plan.tax,
        'total_amount': total,
        'status': plan.status,
      },
    );
    if (result.isEmpty) return null;
    return GymPlanModel.fromMap(result.first.toColumnMap());
  }

  Future<Map<String, dynamic>> deletePlan(int id) async {
    final plan = await getPlanById(id);
    if (plan == null) {
      return {'found': false, 'deleted': false, 'message': 'Plan not found'};
    }

    // Wrap count-check + delete in a transaction to avoid race conditions
    return await postgresService.connection.runTx((session) async {
      // Check if any memberships are referencing this plan
      final checkRes = await session.execute(
        Sql.named('SELECT COUNT(*) as count FROM gym_memberships WHERE plan_id = @id'),
        parameters: {'id': id},
      );
      final count = int.tryParse(checkRes.first.toColumnMap()['count']?.toString() ?? '0') ?? 0;

      if (count > 0) {
        // Soft-delete / Deactivate plan to preserve historical membership & financial data
        await session.execute(
          Sql.named("UPDATE gym_membership_plans SET status = 'INACTIVE', updated_at = CURRENT_TIMESTAMP WHERE id = @id"),
          parameters: {'id': id},
        );
        return {
          'found': true,
          'deleted': true,
          'archived': true,
          'membershipCount': count,
          'message': 'Plan "${plan.name}" is linked to $count membership record(s) and has been deactivated/archived.',
        };
      }

      // Permanently delete if no membership records exist
      final result = await session.execute(
        Sql.named('DELETE FROM gym_membership_plans WHERE id = @id'),
        parameters: {'id': id},
      );
      return {
        'found': true,
        'deleted': result.affectedRows > 0,
        'archived': false,
        'membershipCount': 0,
        'message': 'Plan "${plan.name}" deleted permanently.',
      };
    });
  }

  // ===========================================================================
  // 4. MEMBERSHIPS & RENEWALS
  // ===========================================================================
  Future<List<GymMembershipModel>> getMemberships({
    String? status,
    bool? expiringSoon,
    bool? renewals,
    int? memberId,
    int? limit,
  }) async {
    String query = '''
      SELECT 
        ms.*,
        m.name AS member_name,
        m.member_code,
        m.phone AS member_phone,
        p.name AS plan_name,
        p.duration_days,
        p.price AS plan_price,
        COALESCE(pay.status, 'PAID') AS payment_status,
        pay.invoice_id
      FROM gym_memberships ms
      JOIN gym_members m ON ms.member_id = m.id
      JOIN gym_membership_plans p ON ms.plan_id = p.id
      LEFT JOIN LATERAL (
        SELECT status, invoice_id
        FROM gym_payments
        WHERE membership_id = ms.id
        ORDER BY created_at DESC
        LIMIT 1
      ) pay ON true
      WHERE 1=1
    ''';

    final Map<String, dynamic> params = {};

    if (memberId != null) {
      query += ' AND ms.member_id = @member_id';
      params['member_id'] = memberId;
    }

    if (status != null && status.isNotEmpty && status != 'ALL') {
      query += ' AND ms.status = @status';
      params['status'] = status.toUpperCase();
    }

    if (expiringSoon == true) {
      query += " AND ms.status = 'ACTIVE' AND ms.end_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '7 days')";
    }

    if (renewals == true) {
      query += " AND (ms.status = 'EXPIRED' OR ms.end_date <= (CURRENT_DATE + INTERVAL '7 days'))";
    }

    query += ' ORDER BY ms.created_at DESC';

    if (limit != null && limit > 0) {
      query += ' LIMIT $limit';
    }

    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => GymMembershipModel.fromMap(r.toColumnMap())).toList();
  }

  Future<GymMembershipModel?> getMembershipById(int id) async {
    final list = await _conn.execute(
      Sql.named('''
        SELECT 
          ms.*,
          m.name AS member_name,
          m.member_code,
          m.phone AS member_phone,
          p.name AS plan_name,
          p.duration_days,
          COALESCE(pay.status, 'PAID') AS payment_status,
          pay.invoice_id
        FROM gym_memberships ms
        JOIN gym_members m ON ms.member_id = m.id
        JOIN gym_membership_plans p ON ms.plan_id = p.id
        LEFT JOIN LATERAL (
          SELECT status, invoice_id
          FROM gym_payments
          WHERE membership_id = ms.id
          ORDER BY created_at DESC
          LIMIT 1
        ) pay ON true
        WHERE ms.id = @id
      '''),
      parameters: {'id': id},
    );
    if (list.isEmpty) return null;
    return GymMembershipModel.fromMap(list.first.toColumnMap());
  }

  Future<GymMembershipModel> createMembership(
    GymMembershipModel membership, {
    double? paidAmount,
    String? paymentMethod = 'CASH',
  }) async {
    final plan = await getPlanById(membership.planId);
    DateTime start = membership.startDate;
    DateTime end = membership.endDate;
    if (plan != null && end.isBefore(start)) {
      end = start.add(Duration(days: plan.durationDays));
    }

    final finalAmt = membership.finalAmount > 0
        ? membership.finalAmount
        : (plan != null ? plan.totalAmount : membership.amount);

    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_memberships (
          member_id, plan_id, start_date, end_date, amount, discount, tax, final_amount, status, auto_renew
        )
        VALUES (
          @member_id, @plan_id, @start_date, @end_date, @amount, @discount, @tax, @final_amount, @status, @auto_renew
        )
        RETURNING *
      '''),
      parameters: {
        'member_id': membership.memberId,
        'plan_id': membership.planId,
        'start_date': start.toIso8601String().split('T').first,
        'end_date': end.toIso8601String().split('T').first,
        'amount': membership.amount > 0 ? membership.amount : (plan?.price ?? 0.0),
        'discount': membership.discount,
        'tax': membership.tax,
        'final_amount': finalAmt,
        'status': membership.status,
        'auto_renew': membership.autoRenew,
      },
    );

    final createdMs = GymMembershipModel.fromMap(result.first.toColumnMap());

    // Update Member status to ACTIVE
    await _conn.execute(
      Sql.named("UPDATE gym_members SET status = 'ACTIVE' WHERE id = @id"),
      parameters: {'id': membership.memberId},
    );

    // Create Invoice in ERP sales_orders
    final member = await getMemberById(membership.memberId);
    int? invoiceId;
    try {
      final orderNo = 'GYM-INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final invRes = await _conn.execute(
        Sql.named('''
          INSERT INTO sales_orders (
            order_number, customer_name, customer_id, subtotal, discount, tax, total, status
          )
          VALUES (
            @order_number, @customer_name, @customer_id, @subtotal, @discount, @tax, @total, @status
          )
          RETURNING id
        '''),
        parameters: {
          'order_number': orderNo,
          'customer_name': member?.name ?? 'Gym Member',
          'customer_id': member?.customerId,
          'subtotal': membership.amount > 0 ? membership.amount : (plan?.price ?? finalAmt),
          'discount': membership.discount,
          'tax': membership.tax,
          'total': finalAmt,
          'status': 'completed',
        },
      );
      invoiceId = int.tryParse(invRes.first.toColumnMap()['id'].toString());
    } catch (_) {}

    // Record Payment
    final payAmt = paidAmount ?? finalAmt;
    if (payAmt > 0) {
      final ref = 'GYM-PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      await _conn.execute(
        Sql.named('''
          INSERT INTO gym_payments (
            member_id, membership_id, invoice_id, amount, payment_method, reference_number, status
          )
          VALUES (
            @member_id, @membership_id, @invoice_id, @amount, @payment_method, @reference_number, @status
          )
        '''),
        parameters: {
          'member_id': membership.memberId,
          'membership_id': createdMs.id,
          'invoice_id': invoiceId,
          'amount': payAmt,
          'payment_method': paymentMethod ?? 'CASH',
          'reference_number': ref,
          'status': payAmt >= finalAmt ? 'PAID' : 'PARTIAL',
        },
      );
    }

    return (await getMembershipById(createdMs.id!)) ?? createdMs;
  }

  Future<GymMembershipModel?> renewMembership(
    int membershipId,
    int planId, {
    DateTime? customStartDate,
    double? paidAmount,
    String? paymentMethod = 'CASH',
  }) async {
    final oldMs = await getMembershipById(membershipId);
    if (oldMs == null) return null;

    final plan = await getPlanById(planId);
    if (plan == null) return null;

    // Start date is day after previous end_date or today if already past
    DateTime start = customStartDate ?? (oldMs.endDate.isAfter(DateTime.now()) ? oldMs.endDate.add(const Duration(days: 1)) : DateTime.now());
    DateTime end = start.add(Duration(days: plan.durationDays));

    // Mark previous membership as EXPIRED / RENEWED
    await _conn.execute(
      Sql.named("UPDATE gym_memberships SET status = 'EXPIRED' WHERE id = @id"),
      parameters: {'id': membershipId},
    );

    // Create New Membership Record
    final newMembership = GymMembershipModel(
      memberId: oldMs.memberId,
      planId: plan.id!,
      startDate: start,
      endDate: end,
      amount: plan.price,
      discount: plan.discount,
      tax: plan.tax,
      finalAmount: plan.totalAmount,
      status: 'ACTIVE',
    );

    return createMembership(
      newMembership,
      paidAmount: paidAmount ?? plan.totalAmount,
      paymentMethod: paymentMethod,
    );
  }

  Future<GymMembershipModel?> updateMembership(int id, GymMembershipModel membership) async {
    final result = await _conn.execute(
      Sql.named('''
        UPDATE gym_memberships
        SET
          plan_id = @plan_id,
          start_date = @start_date,
          end_date = @end_date,
          amount = @amount,
          discount = @discount,
          tax = @tax,
          final_amount = @final_amount,
          status = @status,
          auto_renew = @auto_renew,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'plan_id': membership.planId,
        'start_date': membership.startDate.toIso8601String().split('T').first,
        'end_date': membership.endDate.toIso8601String().split('T').first,
        'amount': membership.amount,
        'discount': membership.discount,
        'tax': membership.tax,
        'final_amount': membership.finalAmount,
        'status': membership.status,
        'auto_renew': membership.autoRenew,
      },
    );

    if (result.isEmpty) return null;
    return getMembershipById(id);
  }

  // ===========================================================================
  // 5. TRAINERS & ASSIGNMENTS
  // ===========================================================================
  Future<List<GymTrainerModel>> getTrainers({String? status}) async {
    String query = '''
      SELECT 
        t.*,
        e.employee_id AS employee_code,
        e.full_name AS employee_name,
        COALESCE(t.name, e.full_name, 'Trainer') AS display_name,
        COALESCE(t.phone, e.phone) AS display_phone,
        COALESCE(t.email, e.email) AS display_email,
        COALESCE(assign.member_count, 0)::int AS assigned_member_count
      FROM gym_trainers t
      LEFT JOIN employees e ON t.employee_id = e.id
      LEFT JOIN (
        SELECT trainer_id, COUNT(*) AS member_count
        FROM gym_trainer_assignments
        WHERE status = 'ACTIVE'
        GROUP BY trainer_id
      ) assign ON assign.trainer_id = t.id
      WHERE 1=1
    ''';

    final Map<String, dynamic> params = {};
    if (status != null && status.isNotEmpty && status != 'ALL') {
      query += ' AND t.status = @status';
      params['status'] = status.toUpperCase();
    }

    query += ' ORDER BY t.created_at DESC';
    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) {
      final map = r.toColumnMap();
      map['name'] = map['display_name'];
      map['phone'] = map['display_phone'];
      map['email'] = map['display_email'];
      return GymTrainerModel.fromMap(map);
    }).toList();
  }

  Future<GymTrainerModel?> getTrainerById(int id) async {
    final list = await _conn.execute(
      Sql.named('''
        SELECT 
          t.*,
          e.employee_id AS employee_code,
          e.full_name AS employee_name,
          COALESCE(t.name, e.full_name, 'Trainer') AS display_name,
          COALESCE(t.phone, e.phone) AS display_phone,
          COALESCE(t.email, e.email) AS display_email,
          COALESCE(assign.member_count, 0)::int AS assigned_member_count
        FROM gym_trainers t
        LEFT JOIN employees e ON t.employee_id = e.id
        LEFT JOIN (
          SELECT trainer_id, COUNT(*) AS member_count
          FROM gym_trainer_assignments
          WHERE status = 'ACTIVE'
          GROUP BY trainer_id
        ) assign ON assign.trainer_id = t.id
        WHERE t.id = @id
      '''),
      parameters: {'id': id},
    );
    if (list.isEmpty) return null;
    final map = list.first.toColumnMap();
    map['name'] = map['display_name'];
    map['phone'] = map['display_phone'];
    map['email'] = map['display_email'];
    return GymTrainerModel.fromMap(map);
  }

  Future<GymTrainerModel> createTrainer(GymTrainerModel trainer) async {
    // If employeeId is given, fetch details from employees table if needed
    String name = trainer.name;
    String? phone = trainer.phone;
    String? email = trainer.email;

    if (trainer.employeeId != null) {
      final emp = await _conn.execute(
        Sql.named('SELECT full_name, phone, email FROM employees WHERE id = @id'),
        parameters: {'id': trainer.employeeId},
      );
      if (emp.isNotEmpty) {
        final m = emp.first.toColumnMap();
        name = name.isNotEmpty ? name : (m['full_name']?.toString() ?? 'Trainer');
        phone = phone ?? m['phone']?.toString();
        email = email ?? m['email']?.toString();
      }
    }

    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_trainers (
          employee_id, name, phone, email, specialization, experience, salary, status
        )
        VALUES (
          @employee_id, @name, @phone, @email, @specialization, @experience, @salary, @status
        )
        RETURNING *
      '''),
      parameters: {
        'employee_id': trainer.employeeId,
        'name': name,
        'phone': phone,
        'email': email,
        'specialization': trainer.specialization,
        'experience': trainer.experience,
        'salary': trainer.salary,
        'status': trainer.status,
      },
    );

    return (await getTrainerById(int.parse(result.first.toColumnMap()['id'].toString())))!;
  }

  Future<GymTrainerModel?> updateTrainer(int id, GymTrainerModel trainer) async {
    final result = await _conn.execute(
      Sql.named('''
        UPDATE gym_trainers
        SET
          name = @name,
          phone = @phone,
          email = @email,
          specialization = @specialization,
          experience = @experience,
          salary = @salary,
          status = @status,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'name': trainer.name,
        'phone': trainer.phone,
        'email': trainer.email,
        'specialization': trainer.specialization,
        'experience': trainer.experience,
        'salary': trainer.salary,
        'status': trainer.status,
      },
    );
    if (result.isEmpty) return null;
    return getTrainerById(id);
  }

  Future<bool> deleteTrainer(int id) async {
    final result = await _conn.execute(
      Sql.named('DELETE FROM gym_trainers WHERE id = @id'),
      parameters: {'id': id},
    );
    return result.affectedRows > 0;
  }

  Future<TrainerAssignmentModel> assignMemberToTrainer(
    int memberId,
    int trainerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Deactivate previous active assignments for this member
    await _conn.execute(
      Sql.named("UPDATE gym_trainer_assignments SET status = 'INACTIVE' WHERE member_id = @member_id"),
      parameters: {'member_id': memberId},
    );

    final start = startDate ?? DateTime.now();
    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_trainer_assignments (
          member_id, trainer_id, start_date, end_date, status
        )
        VALUES (
          @member_id, @trainer_id, @start_date, @end_date, 'ACTIVE'
        )
        RETURNING *
      '''),
      parameters: {
        'member_id': memberId,
        'trainer_id': trainerId,
        'start_date': start.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
      },
    );

    return TrainerAssignmentModel.fromMap(result.first.toColumnMap());
  }

  Future<List<GymMemberModel>> getTrainerMembers(int trainerId) async {
    final result = await _conn.execute(
      Sql.named('''
        SELECT 
          m.*,
          ta.start_date AS assignment_start,
          p.name AS current_plan_name,
          ms.end_date AS current_membership_end_date
        FROM gym_trainer_assignments ta
        JOIN gym_members m ON ta.member_id = m.id
        LEFT JOIN LATERAL (
          SELECT plan_id, end_date FROM gym_memberships WHERE member_id = m.id ORDER BY end_date DESC LIMIT 1
        ) ms ON true
        LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
        WHERE ta.trainer_id = @trainer_id AND ta.status = 'ACTIVE'
        ORDER BY ta.created_at DESC
      '''),
      parameters: {'trainer_id': trainerId},
    );
    return result.map((r) => GymMemberModel.fromMap(r.toColumnMap())).toList();
  }

  // ===========================================================================
  // 6. ATTENDANCE (CHECK-IN / CHECK-OUT)
  // ===========================================================================
  Future<GymAttendanceModel> checkIn(int memberId) async {
    // 1. Verify member exists and is active
    final member = await getMemberById(memberId);
    if (member == null) {
      throw Exception('Gym Member not found');
    }
    if (member.status.toUpperCase() != 'ACTIVE') {
      throw Exception('Member status is ${member.status}. Only ACTIVE members can check in.');
    }

    // 2. Check for duplicate open check-in today
    final openAtt = await _conn.execute(
      Sql.named('''
        SELECT * FROM gym_attendance
        WHERE member_id = @member_id 
          AND attendance_date = CURRENT_DATE 
          AND check_out IS NULL
        LIMIT 1
      '''),
      parameters: {'member_id': memberId},
    );
    if (openAtt.isNotEmpty) {
      throw Exception('Member already checked in today at ${openAtt.first.toColumnMap()['check_in']} and has not checked out.');
    }

    final insertRes = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_attendance (member_id, attendance_date, check_in, status)
        VALUES (@member_id, CURRENT_DATE, CURRENT_TIMESTAMP, 'PRESENT')
        RETURNING *
      '''),
      parameters: {'member_id': memberId},
    );

    final attId = int.parse(insertRes.first.toColumnMap()['id'].toString());
    return (await getAttendanceById(attId))!;
  }

  Future<GymAttendanceModel> checkOut(int memberId, {int? attendanceId}) async {
    String query = '''
      UPDATE gym_attendance
      SET check_out = CURRENT_TIMESTAMP
      WHERE member_id = @member_id AND check_out IS NULL
    ''';
    final Map<String, dynamic> params = {'member_id': memberId};

    if (attendanceId != null) {
      query += ' AND id = @id';
      params['id'] = attendanceId;
    }

    query += ' RETURNING *';

    final result = await _conn.execute(Sql.named(query), parameters: params);
    if (result.isEmpty) {
      throw Exception('No open check-in record found for this member today.');
    }

    final attId = int.parse(result.first.toColumnMap()['id'].toString());
    return (await getAttendanceById(attId))!;
  }

  Future<GymAttendanceModel?> getAttendanceById(int id) async {
    final list = await _conn.execute(
      Sql.named('''
        SELECT 
          a.*,
          m.name AS member_name,
          m.member_code,
          m.phone AS member_phone,
          m.photo,
          p.name AS plan_name
        FROM gym_attendance a
        JOIN gym_members m ON a.member_id = m.id
        LEFT JOIN LATERAL (
          SELECT plan_id FROM gym_memberships WHERE member_id = m.id ORDER BY end_date DESC LIMIT 1
        ) ms ON true
        LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
        WHERE a.id = @id
      '''),
      parameters: {'id': id},
    );
    if (list.isEmpty) return null;
    return GymAttendanceModel.fromMap(list.first.toColumnMap());
  }

  Future<List<GymAttendanceModel>> getAttendance({
    DateTime? date,
    int? memberId,
    int? limit,
  }) async {
    String query = '''
      SELECT 
        a.*,
        m.name AS member_name,
        m.member_code,
        m.phone AS member_phone,
        m.photo,
        p.name AS plan_name
      FROM gym_attendance a
      JOIN gym_members m ON a.member_id = m.id
      LEFT JOIN LATERAL (
        SELECT plan_id FROM gym_memberships WHERE member_id = m.id ORDER BY end_date DESC LIMIT 1
      ) ms ON true
      LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
      WHERE 1=1
    ''';

    final Map<String, dynamic> params = {};

    if (date != null) {
      query += ' AND a.attendance_date = @date';
      params['date'] = date.toIso8601String().split('T').first;
    }

    if (memberId != null) {
      query += ' AND a.member_id = @member_id';
      params['member_id'] = memberId;
    }

    query += ' ORDER BY a.check_in DESC';

    if (limit != null && limit > 0) {
      query += ' LIMIT $limit';
    }

    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => GymAttendanceModel.fromMap(r.toColumnMap())).toList();
  }

  // ===========================================================================
  // 7. PAYMENTS & RECEIPTS
  // ===========================================================================
  Future<List<GymPaymentModel>> getPayments({
    String? status,
    int? memberId,
    int? limit,
  }) async {
    String query = '''
      SELECT 
        pay.*,
        m.name AS member_name,
        m.member_code,
        m.phone AS member_phone,
        p.name AS plan_name,
        so.order_number AS invoice_number
      FROM gym_payments pay
      JOIN gym_members m ON pay.member_id = m.id
      LEFT JOIN gym_memberships ms ON pay.membership_id = ms.id
      LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
      LEFT JOIN sales_orders so ON pay.invoice_id = so.id
      WHERE 1=1
    ''';

    final Map<String, dynamic> params = {};

    if (status != null && status.isNotEmpty && status != 'ALL') {
      query += ' AND pay.status = @status';
      params['status'] = status.toUpperCase();
    }

    if (memberId != null) {
      query += ' AND pay.member_id = @member_id';
      params['member_id'] = memberId;
    }

    query += ' ORDER BY pay.payment_date DESC';

    if (limit != null && limit > 0) {
      query += ' LIMIT $limit';
    }

    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => GymPaymentModel.fromMap(r.toColumnMap())).toList();
  }

  Future<GymPaymentModel?> getPaymentById(int id) async {
    final list = await _conn.execute(
      Sql.named('''
        SELECT 
          pay.*,
          m.name AS member_name,
          m.member_code,
          m.phone AS member_phone,
          p.name AS plan_name,
          so.order_number AS invoice_number
        FROM gym_payments pay
        JOIN gym_members m ON pay.member_id = m.id
        LEFT JOIN gym_memberships ms ON pay.membership_id = ms.id
        LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
        LEFT JOIN sales_orders so ON pay.invoice_id = so.id
        WHERE pay.id = @id
      '''),
      parameters: {'id': id},
    );
    if (list.isEmpty) return null;
    return GymPaymentModel.fromMap(list.first.toColumnMap());
  }

  Future<GymPaymentModel> createPayment(GymPaymentModel payment) async {
    String ref = payment.referenceNumber ?? 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_payments (
          member_id, membership_id, invoice_id, amount, payment_method, reference_number, status, notes
        )
        VALUES (
          @member_id, @membership_id, @invoice_id, @amount, @payment_method, @reference_number, @status, @notes
        )
        RETURNING *
      '''),
      parameters: {
        'member_id': payment.memberId,
        'membership_id': payment.membershipId,
        'invoice_id': payment.invoiceId,
        'amount': payment.amount,
        'payment_method': payment.paymentMethod,
        'reference_number': ref,
        'status': payment.status,
        'notes': payment.notes,
      },
    );

    final payId = int.parse(result.first.toColumnMap()['id'].toString());
    return (await getPaymentById(payId))!;
  }

  Future<Map<String, dynamic>?> getPaymentReceipt(int paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment == null) return null;

    final member = await getMemberById(payment.memberId);
    GymMembershipModel? membership;
    if (payment.membershipId != null) {
      membership = await getMembershipById(payment.membershipId!);
    }

    return {
      'receiptNo': payment.referenceNumber ?? 'REC-$paymentId',
      'paymentDate': payment.paymentDate.toIso8601String(),
      'amount': payment.amount,
      'paymentMethod': payment.paymentMethod,
      'status': payment.status,
      'member': {
        'code': member?.memberCode ?? '',
        'name': member?.name ?? '',
        'phone': member?.phone ?? '',
        'email': member?.email ?? '',
      },
      'membership': membership != null
          ? {
              'planName': membership.planName ?? '',
              'startDate': membership.startDate.toIso8601String().split('T').first,
              'endDate': membership.endDate.toIso8601String().split('T').first,
              'totalAmount': membership.finalAmount,
            }
          : null,
      'invoiceNumber': payment.invoiceNumber,
    };
  }

  // ===========================================================================
  // 8. WORKOUT PLANS & EXERCISES
  // ===========================================================================
  Future<List<WorkoutPlanModel>> getWorkoutPlans({int? memberId}) async {
    String query = '''
      SELECT 
        wp.*,
        m.name AS member_name,
        m.member_code,
        t.name AS trainer_name
      FROM gym_workout_plans wp
      JOIN gym_members m ON wp.member_id = m.id
      LEFT JOIN gym_trainers t ON wp.trainer_id = t.id
      WHERE 1=1
    ''';
    final Map<String, dynamic> params = {};

    if (memberId != null) {
      query += ' AND wp.member_id = @member_id';
      params['member_id'] = memberId;
    }

    query += ' ORDER BY wp.created_at DESC';

    final result = await _conn.execute(Sql.named(query), parameters: params);
    final plans = <WorkoutPlanModel>[];

    for (final row in result) {
      final map = row.toColumnMap();
      final planId = int.parse(map['id'].toString());
      final exercises = await getWorkoutExercises(planId);
      map['exercises'] = exercises.map((e) => e.toJson()).toList();
      plans.add(WorkoutPlanModel.fromMap(map));
    }

    return plans;
  }

  Future<WorkoutPlanModel?> getWorkoutPlanById(int id) async {
    final list = await _conn.execute(
      Sql.named('''
        SELECT 
          wp.*,
          m.name AS member_name,
          m.member_code,
          t.name AS trainer_name
        FROM gym_workout_plans wp
        JOIN gym_members m ON wp.member_id = m.id
        LEFT JOIN gym_trainers t ON wp.trainer_id = t.id
        WHERE wp.id = @id
      '''),
      parameters: {'id': id},
    );
    if (list.isEmpty) return null;
    final map = list.first.toColumnMap();
    final exercises = await getWorkoutExercises(id);
    map['exercises'] = exercises.map((e) => e.toJson()).toList();
    return WorkoutPlanModel.fromMap(map);
  }

  Future<List<WorkoutExerciseModel>> getWorkoutExercises(int planId) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM gym_workout_exercises WHERE workout_plan_id = @plan_id ORDER BY id ASC'),
      parameters: {'plan_id': planId},
    );
    return result.map((r) => WorkoutExerciseModel.fromMap(r.toColumnMap())).toList();
  }

  Future<WorkoutPlanModel> createWorkoutPlan(WorkoutPlanModel plan) async {
    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_workout_plans (
          member_id, trainer_id, name, goal, start_date, end_date, status, notes
        )
        VALUES (
          @member_id, @trainer_id, @name, @goal, @start_date, @end_date, @status, @notes
        )
        RETURNING *
      '''),
      parameters: {
        'member_id': plan.memberId,
        'trainer_id': plan.trainerId,
        'name': plan.name,
        'goal': plan.goal,
        'start_date': plan.startDate.toIso8601String().split('T').first,
        'end_date': plan.endDate?.toIso8601String().split('T').first,
        'status': plan.status,
        'notes': plan.notes,
      },
    );

    final planId = int.parse(result.first.toColumnMap()['id'].toString());

    // Insert exercises if provided
    for (final ex in plan.exercises) {
      await addExercise(planId, ex);
    }

    return (await getWorkoutPlanById(planId))!;
  }

  Future<WorkoutPlanModel?> updateWorkoutPlan(int id, WorkoutPlanModel plan) async {
    // Wrap plan update + exercise sync in a transaction
    await postgresService.connection.runTx((session) async {
      final result = await session.execute(
        Sql.named('''
          UPDATE gym_workout_plans
          SET
            name = @name,
            goal = @goal,
            trainer_id = @trainer_id,
            start_date = @start_date,
            end_date = @end_date,
            status = @status,
            notes = @notes,
            updated_at = CURRENT_TIMESTAMP
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': id,
          'name': plan.name,
          'goal': plan.goal,
          'trainer_id': plan.trainerId,
          'start_date': plan.startDate.toIso8601String().split('T').first,
          'end_date': plan.endDate?.toIso8601String().split('T').first,
          'status': plan.status,
          'notes': plan.notes,
        },
      );
      if (result.isEmpty) return;

      // Sync exercises: delete all existing, then re-insert the new list
      await session.execute(
        Sql.named('DELETE FROM gym_workout_exercises WHERE workout_plan_id = @id'),
        parameters: {'id': id},
      );

      for (final ex in plan.exercises) {
        await session.execute(
          Sql.named('''
            INSERT INTO gym_workout_exercises (
              workout_plan_id, exercise_name, muscle_group, sets, reps, weight, duration, notes
            ) VALUES (
              @workout_plan_id, @exercise_name, @muscle_group, @sets, @reps, @weight, @duration, @notes
            )
          '''),
          parameters: {
            'workout_plan_id': id,
            'exercise_name': ex.exerciseName,
            'muscle_group': ex.muscleGroup,
            'sets': ex.sets,
            'reps': ex.reps,
            'weight': ex.weight,
            'duration': ex.duration,
            'notes': ex.notes,
          },
        );
      }
    });
    // Fetch the updated plan after the transaction commits
    return getWorkoutPlanById(id);
  }

  Future<bool> deleteWorkoutPlan(int id) async {
    final result = await _conn.execute(
      Sql.named('DELETE FROM gym_workout_plans WHERE id = @id'),
      parameters: {'id': id},
    );
    return result.affectedRows > 0;
  }

  Future<WorkoutExerciseModel> addExercise(int workoutPlanId, WorkoutExerciseModel exercise) async {
    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_workout_exercises (
          workout_plan_id, exercise_name, muscle_group, sets, reps, weight, duration, notes
        )
        VALUES (
          @workout_plan_id, @exercise_name, @muscle_group, @sets, @reps, @weight, @duration, @notes
        )
        RETURNING *
      '''),
      parameters: {
        'workout_plan_id': workoutPlanId,
        'exercise_name': exercise.exerciseName,
        'muscle_group': exercise.muscleGroup,
        'sets': exercise.sets,
        'reps': exercise.reps,
        'weight': exercise.weight,
        'duration': exercise.duration,
        'notes': exercise.notes,
      },
    );
    return WorkoutExerciseModel.fromMap(result.first.toColumnMap());
  }

  Future<WorkoutExerciseModel?> updateExercise(int exerciseId, WorkoutExerciseModel exercise) async {
    final result = await _conn.execute(
      Sql.named('''
        UPDATE gym_workout_exercises
        SET
          exercise_name = @exercise_name,
          muscle_group = @muscle_group,
          sets = @sets,
          reps = @reps,
          weight = @weight,
          duration = @duration,
          notes = @notes,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': exerciseId,
        'exercise_name': exercise.exerciseName,
        'muscle_group': exercise.muscleGroup,
        'sets': exercise.sets,
        'reps': exercise.reps,
        'weight': exercise.weight,
        'duration': exercise.duration,
        'notes': exercise.notes,
      },
    );
    if (result.isEmpty) return null;
    return WorkoutExerciseModel.fromMap(result.first.toColumnMap());
  }

  Future<bool> deleteExercise(int exerciseId) async {
    final result = await _conn.execute(
      Sql.named('DELETE FROM gym_workout_exercises WHERE id = @id'),
      parameters: {'id': exerciseId},
    );
    return result.affectedRows > 0;
  }

  // ===========================================================================
  // 9. SCHEDULES
  // ===========================================================================
  Future<List<GymScheduleModel>> getSchedules({DateTime? date, int? trainerId}) async {
    String query = '''
      SELECT 
        s.*,
        t.name AS trainer_name,
        t.specialization
      FROM gym_schedules s
      LEFT JOIN gym_trainers t ON s.trainer_id = t.id
      WHERE 1=1
    ''';
    final Map<String, dynamic> params = {};

    if (date != null) {
      query += ' AND s.date = @date';
      params['date'] = date.toIso8601String().split('T').first;
    }

    if (trainerId != null) {
      query += ' AND s.trainer_id = @trainer_id';
      params['trainer_id'] = trainerId;
    }

    query += ' ORDER BY s.date ASC, s.start_time ASC';

    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => GymScheduleModel.fromMap(r.toColumnMap())).toList();
  }

  Future<GymScheduleModel> createSchedule(GymScheduleModel schedule) async {
    final result = await _conn.execute(
      Sql.named('''
        INSERT INTO gym_schedules (
          trainer_id, title, description, start_time, end_time, date, status
        )
        VALUES (
          @trainer_id, @title, @description, @start_time, @end_time, @date, @status
        )
        RETURNING *
      '''),
      parameters: {
        'trainer_id': schedule.trainerId,
        'title': schedule.title,
        'description': schedule.description,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'date': schedule.date.toIso8601String().split('T').first,
        'status': schedule.status,
      },
    );
    return GymScheduleModel.fromMap(result.first.toColumnMap());
  }

  Future<GymScheduleModel?> updateSchedule(int id, GymScheduleModel schedule) async {
    final result = await _conn.execute(
      Sql.named('''
        UPDATE gym_schedules
        SET
          trainer_id = @trainer_id,
          title = @title,
          description = @description,
          start_time = @start_time,
          end_time = @end_time,
          date = @date,
          status = @status,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'trainer_id': schedule.trainerId,
        'title': schedule.title,
        'description': schedule.description,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'date': schedule.date.toIso8601String().split('T').first,
        'status': schedule.status,
      },
    );
    if (result.isEmpty) return null;
    return GymScheduleModel.fromMap(result.first.toColumnMap());
  }

  Future<bool> deleteSchedule(int id) async {
    final result = await _conn.execute(
      Sql.named('DELETE FROM gym_schedules WHERE id = @id'),
      parameters: {'id': id},
    );
    return result.affectedRows > 0;
  }

  // ===========================================================================
  // 10. DETAILED REPORTS
  // ===========================================================================
  Future<List<Map<String, dynamic>>> getMembersReport() async {
    try {
    final result = await _conn.execute('''
      SELECT 
        m.member_code,
        m.name,
        m.phone,
        m.email,
        m.gender,
        m.join_date,
        m.status AS member_status,
        p.name AS membership_plan,
        ms.start_date,
        ms.end_date,
        (ms.end_date - CURRENT_DATE) AS days_remaining,
        COALESCE(pay.total_paid, 0)::numeric AS total_paid
      FROM gym_members m
      LEFT JOIN LATERAL (
        SELECT plan_id, start_date, end_date FROM gym_memberships WHERE member_id = m.id ORDER BY end_date DESC LIMIT 1
      ) ms ON true
      LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
      LEFT JOIN (
        SELECT member_id, SUM(amount) AS total_paid FROM gym_payments WHERE status = 'PAID' GROUP BY member_id
      ) pay ON pay.member_id = m.id
      ORDER BY m.created_at DESC
    ''');
    return result.map((r) => r.toColumnMap()).toList();
    } catch (e) { print('Members report SQL error: $e'); return []; }
  }

  Future<List<Map<String, dynamic>>> getAttendanceReport({DateTime? fromDate, DateTime? toDate}) async {
    try {
    String query = '''
      SELECT 
        a.id,
        m.member_code,
        m.name AS member_name,
        m.phone,
        a.attendance_date,
        a.check_in,
        a.check_out,
        a.status
      FROM gym_attendance a
      JOIN gym_members m ON a.member_id = m.id
      WHERE 1=1
    ''';
    final Map<String, dynamic> params = {};

    if (fromDate != null) {
      query += ' AND a.attendance_date >= @from_date';
      params['from_date'] = fromDate.toIso8601String().split('T').first;
    }
    if (toDate != null) {
      query += ' AND a.attendance_date <= @to_date';
      params['to_date'] = toDate.toIso8601String().split('T').first;
    }

    query += ' ORDER BY a.check_in DESC';
    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => r.toColumnMap()).toList();
    } catch (e) { print('Attendance report SQL error: $e'); return []; }
  }

  Future<List<Map<String, dynamic>>> getRevenueReport({DateTime? fromDate, DateTime? toDate}) async {
    try {
    String query = '''
      SELECT 
        pay.id,
        pay.payment_date,
        pay.reference_number,
        m.member_code,
        m.name AS member_name,
        p.name AS plan_name,
        so.order_number AS invoice_number,
        pay.amount,
        pay.payment_method,
        pay.status
      FROM gym_payments pay
      JOIN gym_members m ON pay.member_id = m.id
      LEFT JOIN gym_memberships ms ON pay.membership_id = ms.id
      LEFT JOIN gym_membership_plans p ON ms.plan_id = p.id
      LEFT JOIN sales_orders so ON pay.invoice_id = so.id
      WHERE 1=1
    ''';
    final Map<String, dynamic> params = {};

    if (fromDate != null) {
      query += ' AND pay.payment_date >= @from_date';
      params['from_date'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      query += ' AND pay.payment_date <= @to_date';
      params['to_date'] = toDate.toIso8601String();
    }

    query += ' ORDER BY pay.payment_date DESC';
    final result = await _conn.execute(Sql.named(query), parameters: params);
    return result.map((r) => r.toColumnMap()).toList();
    } catch (e) { print('Revenue report SQL error: $e'); return []; }
  }

  Future<List<Map<String, dynamic>>> getExpiryReport() async {
    try {
    final result = await _conn.execute('''
      SELECT 
        m.member_code,
        m.name AS member_name,
        m.phone,
        p.name AS plan_name,
        ms.start_date,
        ms.end_date,
        (ms.end_date - CURRENT_DATE) AS days_remaining,
        CASE 
          WHEN ms.end_date < CURRENT_DATE THEN 'EXPIRED'
          WHEN ms.end_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'EXPIRING_SOON'
          ELSE 'ACTIVE'
        END AS expiry_category
      FROM gym_memberships ms
      JOIN gym_members m ON ms.member_id = m.id
      JOIN gym_membership_plans p ON ms.plan_id = p.id
      WHERE ms.status = 'ACTIVE' OR ms.end_date < CURRENT_DATE
      ORDER BY ms.end_date ASC
    ''');
    return result.map((r) => r.toColumnMap()).toList();
    } catch (e) { print('Expiry report SQL error: $e'); return []; }
  }

  Future<List<Map<String, dynamic>>> getTrainersReport() async {
    try {
    final result = await _conn.execute('''
      SELECT 
        t.id,
        t.name AS trainer_name,
        t.specialization,
        t.experience,
        t.salary,
        t.status,
        COUNT(DISTINCT ta.member_id)::int AS total_assigned_members,
        COUNT(DISTINCT CASE WHEN ta.status = 'ACTIVE' THEN ta.member_id END)::int AS active_assignments,
        COUNT(DISTINCT s.id)::int AS total_schedules
      FROM gym_trainers t
      LEFT JOIN gym_trainer_assignments ta ON t.id = ta.trainer_id
      LEFT JOIN gym_schedules s ON t.id = s.trainer_id
      GROUP BY t.id, t.name, t.specialization, t.experience, t.salary, t.status
      ORDER BY t.name ASC
    ''');
    return result.map((r) => r.toColumnMap()).toList();
    } catch (e) { print('Trainers report SQL error: $e'); return []; }
  }
}
