import 'package:shelf_router/shelf_router.dart';
import '../controllers/gym_controller.dart';

Router gymRoutes(GymController controller) {
  final router = Router();

  // 1. Dashboard
  router.get('/dashboard', controller.getDashboard);

  // 2. Members (Special routes before parametric <id> routes)
  router.get('/members/active', controller.getActiveMembers);
  router.get('/members/expired', controller.getExpiredMembers);
  router.get('/members/expiring-soon', controller.getExpiringSoonMembers);

  router.get('/members', controller.getMembers);
  router.post('/members', controller.createMember);
  router.get('/members/<id>', controller.getMemberById);
  router.put('/members/<id>', controller.updateMember);
  router.delete('/members/<id>', controller.deleteMember);

  router.get('/members/<id>/membership', controller.getMemberMembership);
  router.get('/members/<id>/attendance', controller.getMemberAttendance);
  router.get('/members/<id>/payments', controller.getMemberPayments);
  router.get('/members/<id>/workouts', controller.getMemberWorkouts);

  // 3. Plans
  router.get('/plans', controller.getPlans);
  router.post('/plans', controller.createPlan);
  router.get('/plans/<id>', controller.getPlanById);
  router.put('/plans/<id>', controller.updatePlan);
  router.delete('/plans/<id>', controller.deletePlan);

  // 4. Memberships (Special routes first)
  router.get('/memberships/active', controller.getActiveMemberships);
  router.get('/memberships/expired', controller.getExpiredMemberships);
  router.get('/memberships/renewals', controller.getRenewalMemberships);
  router.get('/memberships/expiring-soon', controller.getExpiringSoonMemberships);

  router.get('/memberships', controller.getMemberships);
  router.post('/memberships', controller.createMembership);
  router.get('/memberships/<id>', controller.getMembershipById);
  router.put('/memberships/<id>', controller.updateMembership);
  router.post('/memberships/<id>/renew', controller.renewMembership);

  // 5. Trainers
  router.get('/trainers', controller.getTrainers);
  router.post('/trainers', controller.createTrainer);
  router.get('/trainers/<id>', controller.getTrainerById);
  router.put('/trainers/<id>', controller.updateTrainer);
  router.delete('/trainers/<id>', controller.deleteTrainer);

  router.post('/trainers/<id>/assign-member', controller.assignMemberToTrainer);
  router.get('/trainers/<id>/members', controller.getTrainerMembers);
  router.get('/trainers/<id>/schedule', controller.getTrainerSchedule);

  // 6. Attendance
  router.post('/attendance/check-in', controller.checkIn);
  router.post('/attendance/check-out', controller.checkOut);
  router.get('/attendance/today', controller.getTodayAttendance);
  router.get('/attendance/member/<memberId>', (request, memberId) => controller.getMemberAttendance(request, memberId));
  router.get('/attendance', controller.getAttendance);

  // 7. Payments
  router.get('/payments/pending', controller.getPendingPayments);
  router.get('/payments/history', controller.getPaymentHistory);
  router.get('/payments', controller.getPayments);
  router.post('/payments', controller.createPayment);
  router.get('/payments/<id>', controller.getPaymentById);
  router.post('/payments/<id>/receipt', controller.getPaymentReceipt);
  router.get('/payments/<id>/receipt', controller.getPaymentReceipt);

  // 8. Workouts
  router.get('/workouts', controller.getWorkouts);
  router.post('/workouts', controller.createWorkout);
  router.get('/workouts/<id>', controller.getWorkoutById);
  router.put('/workouts/<id>', controller.updateWorkout);
  router.delete('/workouts/<id>', controller.deleteWorkout);



  // 9. Schedules
  router.get('/schedules', controller.getSchedules);
  router.post('/schedules', controller.createSchedule);
  router.put('/schedules/<id>', controller.updateSchedule);
  router.delete('/schedules/<id>', controller.deleteSchedule);

  // 10. Reports
  router.get('/reports/members', controller.getMembersReport);
  router.get('/reports/attendance', controller.getAttendanceReport);
  router.get('/reports/revenue', controller.getRevenueReport);
  router.get('/reports/expiry', controller.getExpiryReport);
  router.get('/reports/trainers', controller.getTrainersReport);

  return router;
}
