import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:erp_software/backend/services/gym_service.dart';
import 'package:erp_software/backend/utils/response_utils.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/core/models/gym/gym_workout_model.dart';
import 'package:erp_software/core/models/gym/gym_schedule_model.dart';

class GymController {
  final GymService service;

  GymController(this.service);

  // ===========================================================================
  // 1. DASHBOARD
  // ===========================================================================
  Future<Response> getDashboard(Request request) async {
    try {
      final summary = await service.getDashboardSummary();
      return ResponseUtils.success(
        message: 'Gym dashboard summary retrieved',
        data: summary.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to load gym dashboard', error: e.toString());
    }
  }

  // ===========================================================================
  // 2. MEMBERS
  // ===========================================================================
  Future<Response> getMembers(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final status = queryParams['status'];
      final search = queryParams['search'];
      final expiringSoon = queryParams['expiringSoon'] == 'true';
      final limit = int.tryParse(queryParams['limit'] ?? '');

      final members = await service.getMembers(
        status: status,
        search: search,
        expiringSoon: expiringSoon,
        limit: limit,
      );

      return ResponseUtils.success(
        message: 'Gym members retrieved',
        data: members.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to retrieve members', error: e.toString());
    }
  }

  Future<Response> getActiveMembers(Request request) async {
    try {
      final members = await service.getMembers(status: 'ACTIVE');
      return ResponseUtils.success(
        message: 'Active gym members retrieved',
        data: members.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to retrieve active members', error: e.toString());
    }
  }

  Future<Response> getExpiredMembers(Request request) async {
    try {
      final members = await service.getMembers(status: 'EXPIRED');
      return ResponseUtils.success(
        message: 'Expired gym members retrieved',
        data: members.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to retrieve expired members', error: e.toString());
    }
  }

  Future<Response> getExpiringSoonMembers(Request request) async {
    try {
      final members = await service.getMembers(expiringSoon: true);
      return ResponseUtils.success(
        message: 'Expiring soon gym members retrieved',
        data: members.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to retrieve expiring members', error: e.toString());
    }
  }

  Future<Response> getMemberById(Request request, String id) async {
    try {
      final memberId = int.tryParse(id);
      if (memberId == null) return ResponseUtils.badRequest(message: 'Invalid member ID');

      final member = await service.getMemberById(memberId);
      if (member == null) return ResponseUtils.notFound(message: 'Member not found');

      return ResponseUtils.success(
        message: 'Member details retrieved',
        data: member.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get member', error: e.toString());
    }
  }

  Future<Response> createMember(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if ((data['name']?.toString() ?? '').trim().isEmpty) {
        return ResponseUtils.badRequest(message: 'Member name is required');
      }
      if ((data['phone']?.toString() ?? '').trim().isEmpty) {
        return ResponseUtils.badRequest(message: 'Member phone is required');
      }

      final member = GymMemberModel.fromJson(data);
      final planId = data['planId'] != null ? int.tryParse(data['planId'].toString()) : (data['plan_id'] != null ? int.tryParse(data['plan_id'].toString()) : null);
      final paidAmount = data['paidAmount'] != null ? double.tryParse(data['paidAmount'].toString()) : null;
      final paymentMethod = data['paymentMethod']?.toString();
      final trainerId = data['trainerId'] != null ? int.tryParse(data['trainerId'].toString()) : (data['trainer_id'] != null ? int.tryParse(data['trainer_id'].toString()) : null);

      final created = await service.createMember(
        member,
        planId: planId,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        trainerId: trainerId,
      );

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Member registered successfully',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to create member', error: e.toString());
    }
  }

  Future<Response> updateMember(Request request, String id) async {
    try {
      final memberId = int.tryParse(id);
      if (memberId == null) return ResponseUtils.badRequest(message: 'Invalid member ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final member = GymMemberModel.fromJson(data);

      final updated = await service.updateMember(memberId, member);
      if (updated == null) return ResponseUtils.notFound(message: 'Member not found');

      return ResponseUtils.success(
        message: 'Member updated successfully',
        data: updated.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to update member', error: e.toString());
    }
  }

  Future<Response> deleteMember(Request request, String id) async {
    try {
      final memberId = int.tryParse(id);
      if (memberId == null) return ResponseUtils.badRequest(message: 'Invalid member ID');

      final deleted = await service.deleteMember(memberId);
      if (!deleted) return ResponseUtils.notFound(message: 'Member not found');

      return ResponseUtils.success(message: 'Member deleted successfully');
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to delete member', error: e.toString());
    }
  }

  Future<Response> getMemberMembership(Request request, String id) async {
    try {
      final memberId = int.tryParse(id);
      if (memberId == null) return ResponseUtils.badRequest(message: 'Invalid member ID');

      final memberships = await service.getMemberships(memberId: memberId);
      return ResponseUtils.success(
        message: 'Member memberships retrieved',
        data: memberships.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get member memberships', error: e.toString());
    }
  }

  Future<Response> getMemberAttendance(Request request, String id) async {
    try {
      final memberId = int.tryParse(id);
      if (memberId == null) return ResponseUtils.badRequest(message: 'Invalid member ID');

      final attendance = await service.getAttendance(memberId: memberId);
      return ResponseUtils.success(
        message: 'Member attendance history retrieved',
        data: attendance.map((a) => a.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get member attendance', error: e.toString());
    }
  }

  Future<Response> getMemberPayments(Request request, String id) async {
    try {
      final memberId = int.tryParse(id);
      if (memberId == null) return ResponseUtils.badRequest(message: 'Invalid member ID');

      final payments = await service.getPayments(memberId: memberId);
      return ResponseUtils.success(
        message: 'Member payment history retrieved',
        data: payments.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get member payments', error: e.toString());
    }
  }

  Future<Response> getMemberWorkouts(Request request, String id) async {
    try {
      final memberId = int.tryParse(id);
      if (memberId == null) return ResponseUtils.badRequest(message: 'Invalid member ID');

      final workouts = await service.getWorkoutPlans(memberId: memberId);
      return ResponseUtils.success(
        message: 'Member workout plans retrieved',
        data: workouts.map((w) => w.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get member workouts', error: e.toString());
    }
  }

  // ===========================================================================
  // 3. MEMBERSHIP PLANS
  // ===========================================================================
  Future<Response> getPlans(Request request) async {
    try {
      final status = request.url.queryParameters['status'];
      final plans = await service.getPlans(status: status);
      return ResponseUtils.success(
        message: 'Membership plans retrieved',
        data: plans.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get plans', error: e.toString());
    }
  }

  Future<Response> getPlanById(Request request, String id) async {
    try {
      final planId = int.tryParse(id);
      if (planId == null) return ResponseUtils.badRequest(message: 'Invalid plan ID');

      final plan = await service.getPlanById(planId);
      if (plan == null) return ResponseUtils.notFound(message: 'Plan not found');

      return ResponseUtils.success(
        message: 'Plan details retrieved',
        data: plan.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get plan', error: e.toString());
    }
  }

  Future<Response> createPlan(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if ((data['name']?.toString() ?? '').trim().isEmpty) {
        return ResponseUtils.badRequest(message: 'Plan name is required');
      }

      final plan = GymPlanModel.fromJson(data);
      final created = await service.createPlan(plan);

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Plan created successfully',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to create plan', error: e.toString());
    }
  }

  Future<Response> updatePlan(Request request, String id) async {
    try {
      final planId = int.tryParse(id);
      if (planId == null) return ResponseUtils.badRequest(message: 'Invalid plan ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final plan = GymPlanModel.fromJson(data);

      final updated = await service.updatePlan(planId, plan);
      if (updated == null) return ResponseUtils.notFound(message: 'Plan not found');

      return ResponseUtils.success(
        message: 'Plan updated successfully',
        data: updated.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to update plan', error: e.toString());
    }
  }

  Future<Response> deletePlan(Request request, String id) async {
    try {
      final planId = int.tryParse(id);
      if (planId == null) return ResponseUtils.badRequest(message: 'Invalid plan ID');

      final result = await service.deletePlan(planId);
      if (result['found'] == false) return ResponseUtils.notFound(message: 'Plan not found');
      if (result['deleted'] != true) return ResponseUtils.error(message: 'Failed to delete plan');

      return ResponseUtils.success(
        message: result['message'] as String? ?? 'Plan deleted successfully',
        data: result,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to delete plan', error: e.toString());
    }
  }

  // ===========================================================================
  // 4. MEMBERSHIPS
  // ===========================================================================
  Future<Response> getMemberships(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final status = queryParams['status'];
      final expiringSoon = queryParams['expiringSoon'] == 'true';
      final renewals = queryParams['renewals'] == 'true';
      final limit = int.tryParse(queryParams['limit'] ?? '');

      final list = await service.getMemberships(
        status: status,
        expiringSoon: expiringSoon,
        renewals: renewals,
        limit: limit,
      );

      return ResponseUtils.success(
        message: 'Memberships retrieved',
        data: list.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get memberships', error: e.toString());
    }
  }

  Future<Response> getActiveMemberships(Request request) async {
    try {
      final list = await service.getMemberships(status: 'ACTIVE');
      return ResponseUtils.success(
        message: 'Active memberships retrieved',
        data: list.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get active memberships', error: e.toString());
    }
  }

  Future<Response> getExpiredMemberships(Request request) async {
    try {
      final list = await service.getMemberships(status: 'EXPIRED');
      return ResponseUtils.success(
        message: 'Expired memberships retrieved',
        data: list.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get expired memberships', error: e.toString());
    }
  }

  Future<Response> getRenewalMemberships(Request request) async {
    try {
      final list = await service.getMemberships(renewals: true);
      return ResponseUtils.success(
        message: 'Renewal eligible memberships retrieved',
        data: list.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get renewal memberships', error: e.toString());
    }
  }

  Future<Response> getExpiringSoonMemberships(Request request) async {
    try {
      final list = await service.getMemberships(expiringSoon: true);
      return ResponseUtils.success(
        message: 'Expiring memberships retrieved',
        data: list.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get expiring memberships', error: e.toString());
    }
  }

  Future<Response> getMembershipById(Request request, String id) async {
    try {
      final msId = int.tryParse(id);
      if (msId == null) return ResponseUtils.badRequest(message: 'Invalid membership ID');

      final ms = await service.getMembershipById(msId);
      if (ms == null) return ResponseUtils.notFound(message: 'Membership not found');

      return ResponseUtils.success(
        message: 'Membership details retrieved',
        data: ms.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get membership', error: e.toString());
    }
  }

  Future<Response> createMembership(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final membership = GymMembershipModel.fromJson(data);
      final paidAmount = data['paidAmount'] != null ? double.tryParse(data['paidAmount'].toString()) : null;
      final paymentMethod = data['paymentMethod']?.toString() ?? 'CASH';

      final created = await service.createMembership(
        membership,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
      );

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Membership created and invoice issued',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to create membership', error: e.toString());
    }
  }

  Future<Response> renewMembership(Request request, String id) async {
    try {
      final msId = int.tryParse(id);
      if (msId == null) return ResponseUtils.badRequest(message: 'Invalid membership ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final planId = int.tryParse(data['planId']?.toString() ?? data['plan_id']?.toString() ?? '0') ?? 0;
      if (planId <= 0) return ResponseUtils.badRequest(message: 'Valid plan ID is required for renewal');

      final paidAmount = data['paidAmount'] != null ? double.tryParse(data['paidAmount'].toString()) : null;
      final paymentMethod = data['paymentMethod']?.toString() ?? 'CASH';
      final customStartDate = data['startDate'] != null ? DateTime.tryParse(data['startDate'].toString()) : null;

      final renewed = await service.renewMembership(
        msId,
        planId,
        customStartDate: customStartDate,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
      );

      if (renewed == null) return ResponseUtils.notFound(message: 'Failed to renew membership');

      return ResponseUtils.success(
        message: 'Membership renewed successfully',
        data: renewed.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to renew membership', error: e.toString());
    }
  }

  Future<Response> updateMembership(Request request, String id) async {
    try {
      final msId = int.tryParse(id);
      if (msId == null) return ResponseUtils.badRequest(message: 'Invalid membership ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final membership = GymMembershipModel.fromJson(data);

      final updated = await service.updateMembership(msId, membership);
      if (updated == null) return ResponseUtils.notFound(message: 'Membership not found');

      return ResponseUtils.success(
        message: 'Membership updated successfully',
        data: updated.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to update membership', error: e.toString());
    }
  }

  // ===========================================================================
  // 5. TRAINERS
  // ===========================================================================
  Future<Response> getTrainers(Request request) async {
    try {
      final status = request.url.queryParameters['status'];
      final trainers = await service.getTrainers(status: status);
      return ResponseUtils.success(
        message: 'Trainers retrieved',
        data: trainers.map((t) => t.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get trainers', error: e.toString());
    }
  }

  Future<Response> getTrainerById(Request request, String id) async {
    try {
      final trainerId = int.tryParse(id);
      if (trainerId == null) return ResponseUtils.badRequest(message: 'Invalid trainer ID');

      final trainer = await service.getTrainerById(trainerId);
      if (trainer == null) return ResponseUtils.notFound(message: 'Trainer not found');

      return ResponseUtils.success(
        message: 'Trainer details retrieved',
        data: trainer.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get trainer', error: e.toString());
    }
  }

  Future<Response> createTrainer(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final trainer = GymTrainerModel.fromJson(data);
      final created = await service.createTrainer(trainer);

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Trainer profile created',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to create trainer', error: e.toString());
    }
  }

  Future<Response> updateTrainer(Request request, String id) async {
    try {
      final trainerId = int.tryParse(id);
      if (trainerId == null) return ResponseUtils.badRequest(message: 'Invalid trainer ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final trainer = GymTrainerModel.fromJson(data);

      final updated = await service.updateTrainer(trainerId, trainer);
      if (updated == null) return ResponseUtils.notFound(message: 'Trainer not found');

      return ResponseUtils.success(
        message: 'Trainer updated successfully',
        data: updated.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to update trainer', error: e.toString());
    }
  }

  Future<Response> deleteTrainer(Request request, String id) async {
    try {
      final trainerId = int.tryParse(id);
      if (trainerId == null) return ResponseUtils.badRequest(message: 'Invalid trainer ID');

      final deleted = await service.deleteTrainer(trainerId);
      if (!deleted) return ResponseUtils.notFound(message: 'Trainer not found');

      return ResponseUtils.success(message: 'Trainer deleted successfully');
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to delete trainer', error: e.toString());
    }
  }

  Future<Response> assignMemberToTrainer(Request request, String id) async {
    try {
      final trainerId = int.tryParse(id);
      if (trainerId == null) return ResponseUtils.badRequest(message: 'Invalid trainer ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final memberId = int.tryParse(data['memberId']?.toString() ?? data['member_id']?.toString() ?? '0') ?? 0;
      if (memberId <= 0) return ResponseUtils.badRequest(message: 'Valid member ID is required');

      final startDate = data['startDate'] != null ? DateTime.tryParse(data['startDate'].toString()) : null;
      final endDate = data['endDate'] != null ? DateTime.tryParse(data['endDate'].toString()) : null;

      final assignment = await service.assignMemberToTrainer(
        memberId,
        trainerId,
        startDate: startDate,
        endDate: endDate,
      );

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Member assigned to trainer successfully',
        data: assignment.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to assign member to trainer', error: e.toString());
    }
  }

  Future<Response> getTrainerMembers(Request request, String id) async {
    try {
      final trainerId = int.tryParse(id);
      if (trainerId == null) return ResponseUtils.badRequest(message: 'Invalid trainer ID');

      final members = await service.getTrainerMembers(trainerId);
      return ResponseUtils.success(
        message: 'Trainer assigned members retrieved',
        data: members.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get trainer members', error: e.toString());
    }
  }

  Future<Response> getTrainerSchedule(Request request, String id) async {
    try {
      final trainerId = int.tryParse(id);
      if (trainerId == null) return ResponseUtils.badRequest(message: 'Invalid trainer ID');

      final schedules = await service.getSchedules(trainerId: trainerId);
      return ResponseUtils.success(
        message: 'Trainer schedule retrieved',
        data: schedules.map((s) => s.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get trainer schedule', error: e.toString());
    }
  }

  // ===========================================================================
  // 6. ATTENDANCE
  // ===========================================================================
  Future<Response> checkIn(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final memberId = int.tryParse(data['memberId']?.toString() ?? data['member_id']?.toString() ?? '0') ?? 0;
      if (memberId <= 0) return ResponseUtils.badRequest(message: 'Valid member ID is required');

      final att = await service.checkIn(memberId);
      return ResponseUtils.success(
        statusCode: 201,
        message: 'Member checked in successfully at ${att.checkIn}',
        data: att.toJson(),
      );
    } catch (e) {
      return ResponseUtils.badRequest(message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Response> checkOut(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final memberId = int.tryParse(data['memberId']?.toString() ?? data['member_id']?.toString() ?? '0') ?? 0;
      final attendanceId = data['attendanceId'] != null ? int.tryParse(data['attendanceId'].toString()) : null;

      if (memberId <= 0) return ResponseUtils.badRequest(message: 'Valid member ID is required');

      final att = await service.checkOut(memberId, attendanceId: attendanceId);
      return ResponseUtils.success(
        message: 'Member checked out successfully. Duration: ${att.durationString}',
        data: att.toJson(),
      );
    } catch (e) {
      return ResponseUtils.badRequest(message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Response> getAttendance(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final dateStr = queryParams['date'];
      final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
      final memberId = int.tryParse(queryParams['memberId'] ?? '');
      final limit = int.tryParse(queryParams['limit'] ?? '');

      final list = await service.getAttendance(date: date, memberId: memberId, limit: limit);
      return ResponseUtils.success(
        message: 'Attendance records retrieved',
        data: list.map((a) => a.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get attendance', error: e.toString());
    }
  }

  Future<Response> getTodayAttendance(Request request) async {
    try {
      final list = await service.getAttendance(date: DateTime.now());
      return ResponseUtils.success(
        message: "Today's attendance retrieved",
        data: list.map((a) => a.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: "Failed to get today's attendance", error: e.toString());
    }
  }

  // ===========================================================================
  // 7. PAYMENTS
  // ===========================================================================
  Future<Response> getPayments(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final status = queryParams['status'];
      final memberId = int.tryParse(queryParams['memberId'] ?? '');
      final limit = int.tryParse(queryParams['limit'] ?? '');

      final list = await service.getPayments(status: status, memberId: memberId, limit: limit);
      return ResponseUtils.success(
        message: 'Payments retrieved',
        data: list.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get payments', error: e.toString());
    }
  }

  Future<Response> getPendingPayments(Request request) async {
    try {
      final list = await service.getPayments(status: 'PENDING');
      return ResponseUtils.success(
        message: 'Pending payments retrieved',
        data: list.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get pending payments', error: e.toString());
    }
  }

  Future<Response> getPaymentHistory(Request request) async {
    try {
      final list = await service.getPayments();
      return ResponseUtils.success(
        message: 'Payment history retrieved',
        data: list.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get payment history', error: e.toString());
    }
  }

  Future<Response> getPaymentById(Request request, String id) async {
    try {
      final payId = int.tryParse(id);
      if (payId == null) return ResponseUtils.badRequest(message: 'Invalid payment ID');

      final payment = await service.getPaymentById(payId);
      if (payment == null) return ResponseUtils.notFound(message: 'Payment not found');

      return ResponseUtils.success(
        message: 'Payment details retrieved',
        data: payment.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get payment', error: e.toString());
    }
  }

  Future<Response> createPayment(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final payment = GymPaymentModel.fromJson(data);
      final created = await service.createPayment(payment);

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Payment recorded successfully',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to record payment', error: e.toString());
    }
  }

  Future<Response> getPaymentReceipt(Request request, String id) async {
    try {
      final payId = int.tryParse(id);
      if (payId == null) return ResponseUtils.badRequest(message: 'Invalid payment ID');

      final receipt = await service.getPaymentReceipt(payId);
      if (receipt == null) return ResponseUtils.notFound(message: 'Payment not found');

      return ResponseUtils.success(
        message: 'Payment receipt generated',
        data: receipt,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to generate receipt', error: e.toString());
    }
  }

  // ===========================================================================
  // 8. WORKOUTS & EXERCISES
  // ===========================================================================
  Future<Response> getWorkouts(Request request) async {
    try {
      final memberId = int.tryParse(request.url.queryParameters['memberId'] ?? '');
      final list = await service.getWorkoutPlans(memberId: memberId);
      return ResponseUtils.success(
        message: 'Workout plans retrieved',
        data: list.map((w) => w.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get workouts', error: e.toString());
    }
  }

  Future<Response> getWorkoutById(Request request, String id) async {
    try {
      final wpId = int.tryParse(id);
      if (wpId == null) return ResponseUtils.badRequest(message: 'Invalid workout ID');

      final wp = await service.getWorkoutPlanById(wpId);
      if (wp == null) return ResponseUtils.notFound(message: 'Workout plan not found');

      return ResponseUtils.success(
        message: 'Workout plan details retrieved',
        data: wp.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get workout plan', error: e.toString());
    }
  }

  Future<Response> createWorkout(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final wp = WorkoutPlanModel.fromJson(data);
      final created = await service.createWorkoutPlan(wp);

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Workout plan created successfully',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to create workout plan', error: e.toString());
    }
  }

  Future<Response> updateWorkout(Request request, String id) async {
    try {
      final wpId = int.tryParse(id);
      if (wpId == null) return ResponseUtils.badRequest(message: 'Invalid workout ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final wp = WorkoutPlanModel.fromJson(data);

      final updated = await service.updateWorkoutPlan(wpId, wp);
      if (updated == null) return ResponseUtils.notFound(message: 'Workout plan not found');

      return ResponseUtils.success(
        message: 'Workout plan updated successfully',
        data: updated.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to update workout plan', error: e.toString());
    }
  }

  Future<Response> deleteWorkout(Request request, String id) async {
    try {
      final wpId = int.tryParse(id);
      if (wpId == null) return ResponseUtils.badRequest(message: 'Invalid workout ID');

      final deleted = await service.deleteWorkoutPlan(wpId);
      if (!deleted) return ResponseUtils.notFound(message: 'Workout plan not found');

      return ResponseUtils.success(message: 'Workout plan deleted successfully');
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to delete workout plan', error: e.toString());
    }
  }

  Future<Response> addExercise(Request request, String id) async {
    try {
      final planId = int.tryParse(id);
      if (planId == null) return ResponseUtils.badRequest(message: 'Invalid workout plan ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final ex = WorkoutExerciseModel.fromJson(data);

      final created = await service.addExercise(planId, ex);
      return ResponseUtils.success(
        statusCode: 201,
        message: 'Exercise added to workout plan',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to add exercise', error: e.toString());
    }
  }

  Future<Response> updateExercise(Request request, String id, String exerciseId) async {
    try {
      final exId = int.tryParse(exerciseId);
      if (exId == null) return ResponseUtils.badRequest(message: 'Invalid exercise ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final ex = WorkoutExerciseModel.fromJson(data);

      final updated = await service.updateExercise(exId, ex);
      if (updated == null) return ResponseUtils.notFound(message: 'Exercise not found');

      return ResponseUtils.success(
        message: 'Exercise updated successfully',
        data: updated.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to update exercise', error: e.toString());
    }
  }

  Future<Response> deleteExercise(Request request, String id, String exerciseId) async {
    try {
      final exId = int.tryParse(exerciseId);
      if (exId == null) return ResponseUtils.badRequest(message: 'Invalid exercise ID');

      final deleted = await service.deleteExercise(exId);
      if (!deleted) return ResponseUtils.notFound(message: 'Exercise not found');

      return ResponseUtils.success(message: 'Exercise removed from workout plan');
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to delete exercise', error: e.toString());
    }
  }

  // ===========================================================================
  // 9. SCHEDULES
  // ===========================================================================
  Future<Response> getSchedules(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final dateStr = queryParams['date'];
      final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
      final trainerId = int.tryParse(queryParams['trainerId'] ?? '');

      final list = await service.getSchedules(date: date, trainerId: trainerId);
      return ResponseUtils.success(
        message: 'Schedules retrieved',
        data: list.map((s) => s.toJson()).toList(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to get schedules', error: e.toString());
    }
  }

  Future<Response> createSchedule(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final s = GymScheduleModel.fromJson(data);
      final created = await service.createSchedule(s);

      return ResponseUtils.success(
        statusCode: 201,
        message: 'Schedule created successfully',
        data: created.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to create schedule', error: e.toString());
    }
  }

  Future<Response> updateSchedule(Request request, String id) async {
    try {
      final sId = int.tryParse(id);
      if (sId == null) return ResponseUtils.badRequest(message: 'Invalid schedule ID');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final s = GymScheduleModel.fromJson(data);

      final updated = await service.updateSchedule(sId, s);
      if (updated == null) return ResponseUtils.notFound(message: 'Schedule not found');

      return ResponseUtils.success(
        message: 'Schedule updated successfully',
        data: updated.toJson(),
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to update schedule', error: e.toString());
    }
  }

  Future<Response> deleteSchedule(Request request, String id) async {
    try {
      final sId = int.tryParse(id);
      if (sId == null) return ResponseUtils.badRequest(message: 'Invalid schedule ID');

      final deleted = await service.deleteSchedule(sId);
      if (!deleted) return ResponseUtils.notFound(message: 'Schedule not found');

      return ResponseUtils.success(message: 'Schedule deleted successfully');
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to delete schedule', error: e.toString());
    }
  }

  // ===========================================================================
  // 10. REPORTS
  // ===========================================================================
  Future<Response> getMembersReport(Request request) async {
    try {
      final report = await service.getMembersReport();
      return ResponseUtils.success(
        message: 'Members report generated',
        data: report,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to generate members report', error: e.toString());
    }
  }

  Future<Response> getAttendanceReport(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final from = queryParams['fromDate'] != null ? DateTime.tryParse(queryParams['fromDate']!) : null;
      final to = queryParams['toDate'] != null ? DateTime.tryParse(queryParams['toDate']!) : null;

      final report = await service.getAttendanceReport(fromDate: from, toDate: to);
      return ResponseUtils.success(
        message: 'Attendance report generated',
        data: report,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to generate attendance report', error: e.toString());
    }
  }

  Future<Response> getRevenueReport(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final from = queryParams['fromDate'] != null ? DateTime.tryParse(queryParams['fromDate']!) : null;
      final to = queryParams['toDate'] != null ? DateTime.tryParse(queryParams['toDate']!) : null;

      final report = await service.getRevenueReport(fromDate: from, toDate: to);
      return ResponseUtils.success(
        message: 'Revenue report generated',
        data: report,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to generate revenue report', error: e.toString());
    }
  }

  Future<Response> getExpiryReport(Request request) async {
    try {
      final report = await service.getExpiryReport();
      return ResponseUtils.success(
        message: 'Expiry report generated',
        data: report,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to generate expiry report', error: e.toString());
    }
  }

  Future<Response> getTrainersReport(Request request) async {
    try {
      final report = await service.getTrainersReport();
      return ResponseUtils.success(
        message: 'Trainers report generated',
        data: report,
      );
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to generate trainers report', error: e.toString());
    }
  }
}
