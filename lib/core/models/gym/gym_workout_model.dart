class WorkoutExerciseModel {
  final int? id;
  final int? workoutPlanId;
  final String exerciseName;
  final String? muscleGroup;
  final int sets;
  final String reps;
  final String? weight;
  final String? duration;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutExerciseModel({
    this.id,
    this.workoutPlanId,
    required this.exerciseName,
    this.muscleGroup,
    this.sets = 3,
    this.reps = '10-12',
    this.weight,
    this.duration,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutExerciseModel.fromMap(Map<String, dynamic> map) {
    return WorkoutExerciseModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      workoutPlanId: map['workout_plan_id'] != null
          ? int.tryParse(map['workout_plan_id'].toString())
          : (map['workoutPlanId'] != null ? int.tryParse(map['workoutPlanId'].toString()) : null),
      exerciseName: map['exercise_name']?.toString() ?? map['exerciseName']?.toString() ?? '',
      muscleGroup: map['muscle_group']?.toString() ?? map['muscleGroup']?.toString(),
      sets: int.tryParse(map['sets']?.toString() ?? '3') ?? 3,
      reps: map['reps']?.toString() ?? '10-12',
      weight: map['weight']?.toString(),
      duration: map['duration']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) => WorkoutExerciseModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (workoutPlanId != null) 'workout_plan_id': workoutPlanId,
      'exercise_name': exerciseName,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      'sets': sets,
      'reps': reps,
      if (weight != null) 'weight': weight,
      if (duration != null) 'duration': duration,
      if (notes != null) 'notes': notes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (workoutPlanId != null) 'workoutPlanId': workoutPlanId,
      if (workoutPlanId != null) 'workout_plan_id': workoutPlanId,
      'exerciseName': exerciseName,
      'exercise_name': exerciseName,
      'muscleGroup': muscleGroup,
      'muscle_group': muscleGroup,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class WorkoutPlanModel {
  final int? id;
  final int memberId;
  final int? trainerId;
  final String name;
  final String? goal;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<WorkoutExerciseModel> exercises;

  // Joined fields
  final String? memberName;
  final String? memberCode;
  final String? trainerName;

  WorkoutPlanModel({
    this.id,
    required this.memberId,
    this.trainerId,
    required this.name,
    this.goal,
    required this.startDate,
    this.endDate,
    this.status = 'ACTIVE',
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.exercises = const [],
    this.memberName,
    this.memberCode,
    this.trainerName,
  });

  factory WorkoutPlanModel.fromMap(Map<String, dynamic> map) {
    DateTime parseD(dynamic v, [DateTime? fallback]) {
      if (v == null) return fallback ?? DateTime.now();
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    final rawExercises = map['exercises'];
    List<WorkoutExerciseModel> exList = [];
    if (rawExercises is List) {
      exList = rawExercises.map((e) => WorkoutExerciseModel.fromMap(e as Map<String, dynamic>)).toList();
    }

    return WorkoutPlanModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      memberId: int.tryParse(map['member_id']?.toString() ?? map['memberId']?.toString() ?? '0') ?? 0,
      trainerId: map['trainer_id'] != null ? int.tryParse(map['trainer_id'].toString()) : (map['trainerId'] != null ? int.tryParse(map['trainerId'].toString()) : null),
      name: map['name']?.toString() ?? 'Workout Plan',
      goal: map['goal']?.toString(),
      startDate: parseD(map['start_date'] ?? map['startDate']),
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'].toString()) : (map['endDate'] != null ? DateTime.tryParse(map['endDate'].toString()) : null),
      status: map['status']?.toString() ?? 'ACTIVE',
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
      exercises: exList,
      memberName: map['member_name']?.toString() ?? map['memberName']?.toString(),
      memberCode: map['member_code']?.toString() ?? map['memberCode']?.toString(),
      trainerName: map['trainer_name']?.toString() ?? map['trainerName']?.toString(),
    );
  }

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) => WorkoutPlanModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'member_id': memberId,
      if (trainerId != null) 'trainer_id': trainerId,
      'name': name,
      if (goal != null) 'goal': goal,
      'start_date': startDate.toIso8601String().split('T').first,
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'memberId': memberId,
      'member_id': memberId,
      'trainerId': trainerId,
      'trainer_id': trainerId,
      'name': name,
      'goal': goal,
      'startDate': startDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'memberName': memberName,
      'memberCode': memberCode,
      'trainerName': trainerName,
    };
  }
}
