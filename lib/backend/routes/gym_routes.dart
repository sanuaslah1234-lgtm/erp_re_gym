import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:erp_software/core/constants/app_permissions.dart';
import 'package:erp_software/backend/middleware/auth_middleware.dart';
import '../controllers/gym_controller.dart';

Router gymRoutes(GymController controller) {
  final router = Router();

  /// RBAC Permission Wrapper for router handlers with 0, 1, or 2 path parameters
  dynamic guard(String perm, Function handler) {
    final mw = requirePermission(perm);
    if (handler is Future<Response> Function(Request, String, String)) {
      return (Request request, String p1, String p2) {
        return mw((Request req) => handler(req, p1, p2))(request);
      };
    } else if (handler is Future<Response> Function(Request, String)) {
      return (Request request, String p1) {
        return mw((Request req) => handler(req, p1))(request);
      };
    } else if (handler is Future<Response> Function(Request)) {
      return (Request request) {
        return mw(handler)(request);
      };
    }

    return (Request request, [String? p1, String? p2]) {
      return mw((Request req) async {
        if (p2 != null) {
          return await (handler as dynamic)(req, p1, p2);
        } else if (p1 != null) {
          return await (handler as dynamic)(req, p1);
        } else {
          final params = req.params;
          if (params.length >= 2) {
            final vals = params.values.toList();
            return await (handler as dynamic)(req, vals[0], vals[1]);
          } else if (params.length == 1) {
            return await (handler as dynamic)(req, params.values.first);
          }
          return await (handler as dynamic)(req);
        }
      })(request);
    };
  }

  // ===========================================================================
  // 1. DASHBOARD (gym.dashboard.view)
  // ===========================================================================
  router.get('/dashboard', guard(AppPermissions.gymDashboardView, controller.getDashboard));

  // ===========================================================================
  // 2. MEMBERS (gym.members.manage)
  // ===========================================================================
  router.get('/members/active', guard(AppPermissions.gymMembersManage, controller.getActiveMembers));
  router.get('/members/expired', guard(AppPermissions.gymMembersManage, controller.getExpiredMembers));
  router.get('/members/expiring-soon', guard(AppPermissions.gymMembersManage, controller.getExpiringSoonMembers));

  router.get('/members', guard(AppPermissions.gymMembersManage, controller.getMembers));
  router.post('/members', guard(AppPermissions.gymMembersManage, controller.createMember));
  router.get('/members/<id>', guard(AppPermissions.gymMembersManage, controller.getMemberById));
  router.put('/members/<id>', guard(AppPermissions.gymMembersManage, controller.updateMember));
  router.delete('/members/<id>', guard(AppPermissions.gymMembersManage, controller.deleteMember));

  router.get('/members/<id>/membership', guard(AppPermissions.gymMembersManage, controller.getMemberMembership));
  router.get('/members/<id>/attendance', guard(AppPermissions.gymAttendanceManage, controller.getMemberAttendance));
  router.get('/members/<id>/payments', guard(AppPermissions.gymPaymentsManage, controller.getMemberPayments));
  router.get('/members/<id>/workouts', guard(AppPermissions.gymWorkoutsManage, controller.getMemberWorkouts));

  // ===========================================================================
  // 3. PLANS (gym.plans.manage)
  // ===========================================================================
  router.get('/plans', guard(AppPermissions.gymPlansManage, controller.getPlans));
  router.post('/plans', guard(AppPermissions.gymPlansManage, controller.createPlan));
  router.get('/plans/<id>', guard(AppPermissions.gymPlansManage, controller.getPlanById));
  router.put('/plans/<id>', guard(AppPermissions.gymPlansManage, controller.updatePlan));
  router.delete('/plans/<id>', guard(AppPermissions.gymPlansManage, controller.deletePlan));

  // ===========================================================================
  // 4. MEMBERSHIPS (gym.memberships.manage)
  // ===========================================================================
  router.get('/memberships/active', guard(AppPermissions.gymMembershipsManage, controller.getActiveMemberships));
  router.get('/memberships/expired', guard(AppPermissions.gymMembershipsManage, controller.getExpiredMemberships));
  router.get('/memberships/renewals', guard(AppPermissions.gymMembershipsManage, controller.getRenewalMemberships));
  router.get('/memberships/expiring-soon', guard(AppPermissions.gymMembershipsManage, controller.getExpiringSoonMemberships));

  router.get('/memberships', guard(AppPermissions.gymMembershipsManage, controller.getMemberships));
  router.post('/memberships', guard(AppPermissions.gymMembershipsManage, controller.createMembership));
  router.get('/memberships/<id>', guard(AppPermissions.gymMembershipsManage, controller.getMembershipById));
  router.put('/memberships/<id>', guard(AppPermissions.gymMembershipsManage, controller.updateMembership));
  router.post('/memberships/<id>/renew', guard(AppPermissions.gymMembershipsManage, controller.renewMembership));

  // ===========================================================================
  // 5. TRAINERS (gym.trainers.manage)
  // ===========================================================================
  router.get('/trainers', guard(AppPermissions.gymTrainersManage, controller.getTrainers));
  router.post('/trainers', guard(AppPermissions.gymTrainersManage, controller.createTrainer));
  router.get('/trainers/<id>', guard(AppPermissions.gymTrainersManage, controller.getTrainerById));
  router.put('/trainers/<id>', guard(AppPermissions.gymTrainersManage, controller.updateTrainer));
  router.delete('/trainers/<id>', guard(AppPermissions.gymTrainersManage, controller.deleteTrainer));

  router.post('/trainers/<id>/assign-member', guard(AppPermissions.gymTrainersManage, controller.assignMemberToTrainer));
  router.get('/trainers/<id>/members', guard(AppPermissions.gymTrainersManage, controller.getTrainerMembers));
  router.get('/trainers/<id>/schedule', guard(AppPermissions.gymSchedulesManage, controller.getTrainerSchedule));

  // ===========================================================================
  // 6. ATTENDANCE (gym.attendance.manage)
  // ===========================================================================
  router.post('/attendance/check-in', guard(AppPermissions.gymAttendanceManage, controller.checkIn));
  router.post('/attendance/check-out', guard(AppPermissions.gymAttendanceManage, controller.checkOut));
  router.get('/attendance/today', guard(AppPermissions.gymAttendanceManage, controller.getTodayAttendance));
  router.get('/attendance/member/<memberId>', guard(AppPermissions.gymAttendanceManage, (Request req, String memberId) => controller.getMemberAttendance(req, memberId)));
  router.get('/attendance', guard(AppPermissions.gymAttendanceManage, controller.getAttendance));

  // ===========================================================================
  // 7. PAYMENTS (gym.payments.manage)
  // ===========================================================================
  router.get('/payments/pending', guard(AppPermissions.gymPaymentsManage, controller.getPendingPayments));
  router.get('/payments/history', guard(AppPermissions.gymPaymentsManage, controller.getPaymentHistory));
  router.get('/payments', guard(AppPermissions.gymPaymentsManage, controller.getPayments));
  router.post('/payments', guard(AppPermissions.gymPaymentsManage, controller.createPayment));
  router.get('/payments/<id>', guard(AppPermissions.gymPaymentsManage, controller.getPaymentById));
  router.post('/payments/<id>/receipt', guard(AppPermissions.gymPaymentsManage, controller.getPaymentReceipt));
  // ===========================================================================
  // 8. WORKOUTS (gym.workouts.manage)
  // ===========================================================================
  router.get('/workouts', guard(AppPermissions.gymWorkoutsManage, controller.getWorkouts));
  router.post('/workouts', guard(AppPermissions.gymWorkoutsManage, controller.createWorkout));
  router.get('/workouts/<id>', guard(AppPermissions.gymWorkoutsManage, controller.getWorkoutById));
  router.put('/workouts/<id>', guard(AppPermissions.gymWorkoutsManage, controller.updateWorkout));
  router.delete('/workouts/<id>', guard(AppPermissions.gymWorkoutsManage, controller.deleteWorkout));

  router.post('/workouts/<id>/exercises', guard(AppPermissions.gymWorkoutsManage, controller.addExercise));
  router.put('/workouts/<id>/exercises/<exerciseId>', guard(AppPermissions.gymWorkoutsManage, controller.updateExercise));
  router.delete('/workouts/<id>/exercises/<exerciseId>', guard(AppPermissions.gymWorkoutsManage, controller.deleteExercise));

  // ===========================================================================
  // 9. SCHEDULES (gym.schedules.manage)
  // ===========================================================================
  router.get('/schedules', guard(AppPermissions.gymSchedulesManage, controller.getSchedules));
  router.post('/schedules', guard(AppPermissions.gymSchedulesManage, controller.createSchedule));
  router.put('/schedules/<id>', guard(AppPermissions.gymSchedulesManage, controller.updateSchedule));
  router.delete('/schedules/<id>', guard(AppPermissions.gymSchedulesManage, controller.deleteSchedule));

  // ===========================================================================
  // 10. REPORTS (gym.reports.view)
  // ===========================================================================
  router.get('/reports/members', guard(AppPermissions.gymReportsView, controller.getMembersReport));
  router.get('/reports/attendance', guard(AppPermissions.gymReportsView, controller.getAttendanceReport));
  router.get('/reports/revenue', guard(AppPermissions.gymReportsView, controller.getRevenueReport));
  router.get('/reports/expiry', guard(AppPermissions.gymReportsView, controller.getExpiryReport));
  router.get('/reports/trainers', guard(AppPermissions.gymReportsView, controller.getTrainersReport));

  return router;
}
