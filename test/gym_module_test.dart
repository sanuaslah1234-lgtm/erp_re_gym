import 'package:flutter_test/flutter_test.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/core/models/gym/gym_trainer_model.dart';
import 'package:erp_software/core/models/gym/gym_attendance_model.dart';
import 'package:erp_software/core/models/gym/gym_payment_model.dart';
import 'package:erp_software/core/models/gym/gym_workout_model.dart';
import 'package:erp_software/core/models/gym/gym_schedule_model.dart';
import 'package:erp_software/core/models/gym/gym_dashboard_model.dart';

void main() {
  group('Gym Module Unit Tests', () {
    test('GymPlanModel calculations and JSON serialization', () {
      final plan = GymPlanModel(
        id: 1,
        name: 'Quarterly Pro',
        durationDays: 90,
        price: 4000.0,
        discount: 500.0,
        tax: 350.0,
        totalAmount: 3850.0,
        status: 'ACTIVE',
      );

      final json = plan.toJson();
      expect(json['name'], 'Quarterly Pro');
      expect(json['duration_days'], 90);
      expect(json['total_amount'], 3850.0);

      final reconstructed = GymPlanModel.fromJson(json);
      expect(reconstructed.name, 'Quarterly Pro');
      expect(reconstructed.durationDays, 90);
      expect(reconstructed.totalAmount, 3850.0);
    });

    test('GymMemberModel status indicators', () {
      final activeMember = GymMemberModel(
        id: 101,
        memberCode: 'GYM-001',
        name: 'Alex Johnson',
        phone: '+1234567890',
        joinDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'ACTIVE',
        daysRemaining: 20,
      );

      expect(activeMember.isActive, true);
      expect(activeMember.isExpired, false);
      expect(activeMember.isExpiringSoon, false);

      final expiringMember = GymMemberModel(
        id: 102,
        memberCode: 'GYM-002',
        name: 'Sara Connor',
        phone: '+1987654321',
        joinDate: DateTime.now().subtract(const Duration(days: 85)),
        status: 'ACTIVE',
        daysRemaining: 4,
      );

      expect(expiringMember.isExpiringSoon, true);

      final expiredMember = GymMemberModel(
        id: 103,
        memberCode: 'GYM-003',
        name: 'John Doe',
        phone: '+1555555555',
        joinDate: DateTime.now().subtract(const Duration(days: 120)),
        status: 'EXPIRED',
        daysRemaining: -10,
      );

      expect(expiredMember.isExpired, true);
    });

    test('GymMembershipModel date calculations and serialization', () {
      final startDate = DateTime.now().subtract(const Duration(days: 10));
      final endDate = DateTime.now().add(const Duration(days: 20));

      final ms = GymMembershipModel(
        id: 5,
        memberId: 101,
        planId: 1,
        startDate: startDate,
        endDate: endDate,
        amount: 1500.0,
        discount: 0.0,
        tax: 0.0,
        finalAmount: 1500.0,
        status: 'ACTIVE',
      );

      expect(ms.isActive, true);
      expect(ms.isExpired, false);
      expect(ms.daysLeft, greaterThanOrEqualTo(19));

      final map = ms.toMap();
      final fromMap = GymMembershipModel.fromMap(map);
      expect(fromMap.memberId, 101);
      expect(fromMap.finalAmount, 1500.0);
    });

    test('GymAttendanceModel check-in/out duration formatting', () {
      final now = DateTime.now();
      final checkInTime = now.subtract(const Duration(hours: 1, minutes: 45));
      final checkOutTime = now;

      final att = GymAttendanceModel(
        id: 1,
        memberId: 101,
        attendanceDate: now,
        checkIn: checkInTime,
        checkOut: checkOutTime,
        status: 'PRESENT',
      );

      expect(att.durationString, contains('1h 45m'));

      final ongoingAtt = GymAttendanceModel(
        id: 2,
        memberId: 102,
        attendanceDate: now,
        checkIn: checkInTime,
        checkOut: null,
        status: 'PRESENT',
      );

      expect(ongoingAtt.durationString, 'In Progress');
    });

    test('GymPaymentModel json mapping', () {
      final payment = GymPaymentModel(
        id: 10,
        memberId: 101,
        amount: 1500.0,
        paymentMethod: 'CARD',
        paymentDate: DateTime.now(),
        referenceNumber: 'PAY-12345',
        status: 'PAID',
      );

      final json = payment.toJson();
      expect(json['payment_method'], 'CARD');
      expect(json['amount'], 1500.0);
      expect(json['reference_number'], 'PAY-12345');
    });

    test('GymWorkoutModel exercises structure', () {
      final exercises = [
        WorkoutExerciseModel(exerciseName: 'Bench Press', muscleGroup: 'Chest', sets: 4, reps: '8-10', weight: '80kg'),
        WorkoutExerciseModel(exerciseName: 'Incline Dumbbell Press', muscleGroup: 'Chest', sets: 3, reps: '10-12', weight: '24kg'),
      ];

      final workout = WorkoutPlanModel(
        id: 1,
        memberId: 101,
        name: 'Chest Hypertrophy',
        goal: 'Muscle Mass',
        startDate: DateTime.now(),
        exercises: exercises,
      );

      expect(workout.exercises.length, 2);
      expect(workout.exercises.first.exerciseName, 'Bench Press');
      expect(workout.exercises.first.muscleGroup, 'Chest');
    });

    test('GymTrainerModel and GymScheduleModel mapping', () {
      final trainer = GymTrainerModel(
        id: 1,
        name: 'Coach Sarah',
        specialization: 'HIIT & Functional',
        experience: '5 Years',
        salary: 3500.0,
        status: 'ACTIVE',
      );
      expect(trainer.name, 'Coach Sarah');
      expect(trainer.isActive, true);

      final schedule = GymScheduleModel(
        id: 1,
        trainerId: 1,
        title: 'Morning Yoga Bootcamp',
        date: DateTime.now(),
        startTime: '06:30 AM',
        endTime: '07:30 AM',
        status: 'SCHEDULED',
      );
      expect(schedule.title, 'Morning Yoga Bootcamp');
      expect(schedule.startTime, '06:30 AM');
    });

    test('GymDashboardModel metrics parsing', () {
      final dashboard = GymDashboardModel(
        totalMembers: 50,
        activeMembers: 42,
        expiredMembers: 6,
        expiringSoon: 2,
        todayAttendance: 18,
        todayRevenue: 4500.0,
        pendingPayments: 1200.0,
        recentMembers: [],
        recentPayments: [],
        expiringMemberships: [],
        monthlyRevenueData: [{'month': 'Jan 2026', 'amount': 15000}],
        attendanceTrend: [{'day': 'Mon', 'count': 22}],
      );

      expect(dashboard.totalMembers, 50);
      expect(dashboard.activeMembers, 42);
      expect(dashboard.todayRevenue, 4500.0);
    });
  });
}
