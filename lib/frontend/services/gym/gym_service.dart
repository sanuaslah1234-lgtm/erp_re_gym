import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/constants/app_constants.dart';
import 'package:erp_software/core/models/gym/gym_dashboard_model.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/gym/gym_attendance_model.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/core/models/gym/gym_workout_model.dart';
import 'package:erp_software/core/models/gym/gym_schedule_model.dart';

class GymApiService {
  static String get baseUrl => AppConstants.apiBaseUrl;
  static String? authToken;

  static void setAuthToken(String? token) {
    authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null && authToken!.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      };

  String _extractError(http.Response res, String fallback) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map) {
        if (body['message'] != null && body['message'].toString().trim().isNotEmpty) {
          return body['message'].toString();
        }
        if (body['error'] != null && body['error'].toString().trim().isNotEmpty) {
          return body['error'].toString();
        }
      }
    } catch (_) {}
    return fallback;
  }

  // ===========================================================================
  // 1. DASHBOARD
  // ===========================================================================
  Future<GymDashboardModel> getDashboard() async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/dashboard'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return GymDashboardModel.fromJson(body['data'] ?? {});
    }
    throw Exception(_extractError(res, 'Failed to load dashboard'));
  }

  // ===========================================================================
  // 2. MEMBERS
  // ===========================================================================
  Future<List<GymMemberModel>> getMembers({
    String? status,
    String? search,
    bool? expiringSoon,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'ALL') queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (expiringSoon == true) queryParams['expiringSoon'] = 'true';
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$baseUrl/api/gym/members').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymMemberModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception(_extractError(res, 'Failed to load members'));
  }

  Future<GymMemberModel> getMemberById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/members/$id'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return GymMemberModel.fromJson(body['data']);
    }
    throw Exception('Member not found');
  }

  Future<GymMemberModel> createMember(
    GymMemberModel member, {
    int? planId,
    double? paidAmount,
    String? paymentMethod,
    int? trainerId,
  }) async {
    final payload = member.toJson();
    if (planId != null) payload['planId'] = planId;
    if (paidAmount != null) payload['paidAmount'] = paidAmount;
    if (paymentMethod != null) payload['paymentMethod'] = paymentMethod;
    if (trainerId != null) payload['trainerId'] = trainerId;

    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/members'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return GymMemberModel.fromJson(body['data']);
    }
    throw Exception('Failed to create member: ${res.body}');
  }

  Future<GymMemberModel> updateMember(int id, GymMemberModel member) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/gym/members/$id'),
      headers: _headers,
      body: jsonEncode(member.toJson()),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return GymMemberModel.fromJson(body['data']);
    }
    throw Exception('Failed to update member: ${res.body}');
  }

  Future<void> deleteMember(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/gym/members/$id'), headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete member: ${res.body}');
    }
  }

  Future<List<GymMembershipModel>> getMemberMembership(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/members/$id/membership'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymMembershipModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<GymAttendanceModel>> getMemberAttendance(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/members/$id/attendance'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymAttendanceModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<GymPaymentModel>> getMemberPayments(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/members/$id/payments'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymPaymentModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<WorkoutPlanModel>> getMemberWorkouts(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/members/$id/workouts'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => WorkoutPlanModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // ===========================================================================
  // 3. PLANS
  // ===========================================================================
  Future<List<GymPlanModel>> getPlans({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'ALL') queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/api/gym/plans').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymPlanModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception(_extractError(res, 'Failed to load plans'));
  }

  Future<GymPlanModel> getPlanById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/plans/$id'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return GymPlanModel.fromJson(body['data']);
    }
    throw Exception(_extractError(res, 'Plan not found'));
  }

  Future<GymPlanModel> createPlan(GymPlanModel plan) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/plans'),
      headers: _headers,
      body: jsonEncode(plan.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return GymPlanModel.fromJson(body['data']);
    }
    throw Exception(_extractError(res, 'Failed to create plan'));
  }

  Future<GymPlanModel> updatePlan(int id, GymPlanModel plan) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/gym/plans/$id'),
      headers: _headers,
      body: jsonEncode(plan.toJson()),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return GymPlanModel.fromJson(body['data']);
    }
    throw Exception(_extractError(res, 'Failed to update plan'));
  }

  Future<Map<String, dynamic>> deletePlan(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/gym/plans/$id'), headers: _headers);
    if (res.statusCode == 200) {
      try {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic>) {
          return body;
        }
      } catch (_) {}
      return {'success': true, 'message': 'Plan deleted successfully'};
    }
    throw Exception(_extractError(res, 'Failed to delete plan'));
  }

  // ===========================================================================
  // 4. MEMBERSHIPS
  // ===========================================================================
  Future<List<GymMembershipModel>> getMemberships({
    String? status,
    bool? expiringSoon,
    bool? renewals,
    int? memberId,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'ALL') queryParams['status'] = status;
    if (expiringSoon == true) queryParams['expiringSoon'] = 'true';
    if (renewals == true) queryParams['renewals'] = 'true';
    if (memberId != null) queryParams['memberId'] = memberId.toString();

    final uri = Uri.parse('$baseUrl/api/gym/memberships').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymMembershipModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load memberships: ${res.body}');
  }

  Future<GymMembershipModel> createMembership(
    GymMembershipModel membership, {
    double? paidAmount,
    String? paymentMethod,
  }) async {
    final payload = membership.toJson();
    if (paidAmount != null) payload['paidAmount'] = paidAmount;
    if (paymentMethod != null) payload['paymentMethod'] = paymentMethod;

    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/memberships'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return GymMembershipModel.fromJson(body['data']);
    }
    throw Exception('Failed to create membership: ${res.body}');
  }

  Future<GymMembershipModel> renewMembership(
    int membershipId,
    int planId, {
    DateTime? customStartDate,
    double? paidAmount,
    String? paymentMethod,
  }) async {
    final payload = <String, dynamic>{'planId': planId};
    if (customStartDate != null) payload['startDate'] = customStartDate.toIso8601String();
    if (paidAmount != null) payload['paidAmount'] = paidAmount;
    if (paymentMethod != null) payload['paymentMethod'] = paymentMethod;

    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/memberships/$membershipId/renew'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return GymMembershipModel.fromJson(body['data']);
    }
    throw Exception('Failed to renew membership: ${res.body}');
  }

  // ===========================================================================
  // 5. TRAINERS
  // ===========================================================================
  Future<List<GymTrainerModel>> getTrainers({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'ALL') queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/api/gym/trainers').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymTrainerModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception(_extractError(res, 'Failed to load trainers'));
  }

  Future<GymTrainerModel> createTrainer(GymTrainerModel trainer) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/trainers'),
      headers: _headers,
      body: jsonEncode(trainer.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return GymTrainerModel.fromJson(body['data']);
    }
    throw Exception('Failed to create trainer: ${res.body}');
  }

  Future<GymTrainerModel> updateTrainer(int id, GymTrainerModel trainer) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/gym/trainers/$id'),
      headers: _headers,
      body: jsonEncode(trainer.toJson()),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return GymTrainerModel.fromJson(body['data']);
    }
    throw Exception('Failed to update trainer: ${res.body}');
  }

  Future<void> deleteTrainer(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/gym/trainers/$id'), headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete trainer: ${res.body}');
    }
  }

  Future<TrainerAssignmentModel> assignMemberToTrainer(
    int trainerId,
    int memberId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final payload = <String, dynamic>{'memberId': memberId};
    if (startDate != null) payload['startDate'] = startDate.toIso8601String();
    if (endDate != null) payload['endDate'] = endDate.toIso8601String();

    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/trainers/$trainerId/assign-member'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return TrainerAssignmentModel.fromJson(body['data']);
    }
    throw Exception('Failed to assign member: ${res.body}');
  }

  Future<List<GymMemberModel>> getTrainerMembers(int trainerId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/trainers/$trainerId/members'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymMemberModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // ===========================================================================
  // 6. ATTENDANCE
  // ===========================================================================
  Future<GymAttendanceModel> checkIn(int memberId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/attendance/check-in'),
      headers: _headers,
      body: jsonEncode({'memberId': memberId}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return GymAttendanceModel.fromJson(body['data']);
    }
    throw Exception(body['message'] ?? 'Check-in failed');
  }

  Future<GymAttendanceModel> checkInMember(int memberId) => checkIn(memberId);

  Future<GymAttendanceModel> checkOut(int memberId, {int? attendanceId}) async {
    final payload = <String, dynamic>{'memberId': memberId};
    if (attendanceId != null) payload['attendanceId'] = attendanceId;

    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/attendance/check-out'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return GymAttendanceModel.fromJson(body['data']);
    }
    throw Exception(body['message'] ?? 'Check-out failed');
  }

  Future<GymAttendanceModel> checkOutMember(int attendanceId, {required int memberId}) => checkOut(memberId, attendanceId: attendanceId);

  Future<List<GymAttendanceModel>> getAttendance({DateTime? date, int? memberId}) async {
    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date.toIso8601String().split('T').first;
    if (memberId != null) queryParams['memberId'] = memberId.toString();

    final uri = Uri.parse('$baseUrl/api/gym/attendance').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymAttendanceModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load attendance: ${res.body}');
  }

  Future<List<GymAttendanceModel>> getTodayAttendance() async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/attendance/today'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymAttendanceModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load today attendance');
  }

  // ===========================================================================
  // 7. PAYMENTS
  // ===========================================================================
  Future<List<GymPaymentModel>> getPayments({String? status, int? memberId}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'ALL') queryParams['status'] = status;
    if (memberId != null) queryParams['memberId'] = memberId.toString();

    final uri = Uri.parse('$baseUrl/api/gym/payments').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymPaymentModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load payments: ${res.body}');
  }

  Future<GymPaymentModel> createPayment(GymPaymentModel payment) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/payments'),
      headers: _headers,
      body: jsonEncode(payment.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return GymPaymentModel.fromJson(body['data']);
    }
    throw Exception('Failed to record payment: ${res.body}');
  }

  Future<Map<String, dynamic>> getPaymentReceipt(int paymentId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/payments/$paymentId/receipt'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Map<String, dynamic>.from(body['data'] ?? {});
    }
    throw Exception('Receipt not found');
  }

  // ===========================================================================
  // 8. WORKOUTS
  // ===========================================================================
  Future<List<WorkoutPlanModel>> getWorkouts({int? memberId}) async {
    final queryParams = <String, String>{};
    if (memberId != null) queryParams['memberId'] = memberId.toString();

    final uri = Uri.parse('$baseUrl/api/gym/workouts').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => WorkoutPlanModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception(_extractError(res, 'Failed to load workouts'));
  }

  Future<WorkoutPlanModel> createWorkoutPlan(WorkoutPlanModel plan) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/workouts'),
      headers: _headers,
      body: jsonEncode(plan.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return WorkoutPlanModel.fromJson(body['data']);
    }
    throw Exception(_extractError(res, 'Failed to create workout plan'));
  }

  Future<WorkoutPlanModel> updateWorkoutPlan(int id, WorkoutPlanModel plan) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/gym/workouts/$id'),
      headers: _headers,
      body: jsonEncode(plan.toJson()),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return WorkoutPlanModel.fromJson(body['data']);
    }
    throw Exception(_extractError(res, 'Failed to update workout plan'));
  }

  Future<void> deleteWorkoutPlan(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/gym/workouts/$id'), headers: _headers);
    if (res.statusCode != 200) {
      throw Exception(_extractError(res, 'Failed to delete workout plan'));
    }
  }

  Future<WorkoutExerciseModel> addExercise(int planId, WorkoutExerciseModel exercise) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/workouts/$planId/exercises'),
      headers: _headers,
      body: jsonEncode(exercise.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return WorkoutExerciseModel.fromJson(body['data']);
    }
    throw Exception('Failed to add exercise: ${res.body}');
  }

  Future<void> deleteExercise(int planId, int exerciseId) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/gym/workouts/$planId/exercises/$exerciseId'), headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete exercise');
    }
  }

  // ===========================================================================
  // 9. SCHEDULES
  // ===========================================================================
  Future<List<GymScheduleModel>> getSchedules({DateTime? date, int? trainerId}) async {
    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date.toIso8601String().split('T').first;
    if (trainerId != null) queryParams['trainerId'] = trainerId.toString();

    final uri = Uri.parse('$baseUrl/api/gym/schedules').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((json) => GymScheduleModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load schedules: ${res.body}');
  }

  Future<GymScheduleModel> createSchedule(GymScheduleModel schedule) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/gym/schedules'),
      headers: _headers,
      body: jsonEncode(schedule.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return GymScheduleModel.fromJson(body['data']);
    }
    throw Exception('Failed to create schedule: ${res.body}');
  }

  Future<GymScheduleModel> updateSchedule(int id, GymScheduleModel schedule) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/gym/schedules/$id'),
      headers: _headers,
      body: jsonEncode(schedule.toJson()),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return GymScheduleModel.fromJson(body['data']);
    }
    throw Exception('Failed to update schedule: ${res.body}');
  }

  Future<void> deleteSchedule(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/gym/schedules/$id'), headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete schedule');
    }
  }

  Future<List<WorkoutPlanModel>> getWorkoutPlans({int? memberId}) => getWorkouts(memberId: memberId);

  // ===========================================================================
  // 10. REPORTS
  // ===========================================================================
  Future<List<Map<String, dynamic>>> getMemberReport({DateTime? startDate, DateTime? endDate}) => getMembersReport(startDate: startDate, endDate: endDate);

  Future<List<Map<String, dynamic>>> getMembersReport({DateTime? startDate, DateTime? endDate}) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['fromDate'] = startDate.toIso8601String().split('T').first;
    if (endDate != null) queryParams['toDate'] = endDate.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/api/gym/reports/members').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Failed to load members report');
  }

  Future<List<Map<String, dynamic>>> getAttendanceReport({DateTime? startDate, DateTime? endDate, DateTime? fromDate, DateTime? toDate}) async {
    final from = startDate ?? fromDate;
    final to = endDate ?? toDate;
    final queryParams = <String, String>{};
    if (from != null) queryParams['fromDate'] = from.toIso8601String().split('T').first;
    if (to != null) queryParams['toDate'] = to.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/api/gym/reports/attendance').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Failed to load attendance report');
  }

  Future<List<Map<String, dynamic>>> getRevenueReport({DateTime? startDate, DateTime? endDate, DateTime? fromDate, DateTime? toDate}) async {
    final from = startDate ?? fromDate;
    final to = endDate ?? toDate;
    final queryParams = <String, String>{};
    if (from != null) queryParams['fromDate'] = from.toIso8601String().split('T').first;
    if (to != null) queryParams['toDate'] = to.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/api/gym/reports/revenue').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Failed to load revenue report');
  }

  Future<List<Map<String, dynamic>>> getExpiryReport() async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/reports/expiry'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Failed to load expiry report');
  }

  Future<List<Map<String, dynamic>>> getTrainerReport() => getTrainersReport();

  Future<List<Map<String, dynamic>>> getTrainersReport() async {
    final res = await http.get(Uri.parse('$baseUrl/api/gym/reports/trainers'), headers: _headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List data = body['data'] ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception('Failed to load trainers report');
  }
}
