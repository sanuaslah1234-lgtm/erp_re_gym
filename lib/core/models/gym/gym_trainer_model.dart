class GymTrainerModel {
  final int? id;
  final int? employeeId;
  final String name;
  final String? phone;
  final String? email;
  final String specialization;
  final String? experience;
  final double salary;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined / Helper attributes
  final int assignedMemberCount;
  final String? employeeCode;

  GymTrainerModel({
    this.id,
    this.employeeId,
    required this.name,
    this.phone,
    this.email,
    required this.specialization,
    this.experience,
    this.salary = 0.0,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
    this.assignedMemberCount = 0,
    this.employeeCode,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory GymTrainerModel.fromMap(Map<String, dynamic> map) {
    return GymTrainerModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      employeeId: map['employee_id'] != null
          ? int.tryParse(map['employee_id'].toString())
          : (map['employeeId'] != null ? int.tryParse(map['employeeId'].toString()) : null),
      name: map['name']?.toString() ?? map['full_name']?.toString() ?? '',
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      specialization: map['specialization']?.toString() ?? 'General Fitness',
      experience: map['experience']?.toString(),
      salary: double.tryParse(map['salary']?.toString() ?? '0') ?? 0.0,
      status: map['status']?.toString() ?? 'ACTIVE',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
      assignedMemberCount: int.tryParse(map['assigned_member_count']?.toString() ?? map['member_count']?.toString() ?? '0') ?? 0,
      employeeCode: map['employee_code']?.toString() ?? map['employee_id_str']?.toString(),
    );
  }

  factory GymTrainerModel.fromJson(Map<String, dynamic> json) => GymTrainerModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'specialization': specialization,
      if (experience != null) 'experience': experience,
      'salary': salary,
      'status': status,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (employeeId != null) 'employeeId': employeeId,
      if (employeeId != null) 'employee_id': employeeId,
      'name': name,
      'phone': phone,
      'email': email,
      'specialization': specialization,
      'experience': experience,
      'salary': salary,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'assigned_member_count': assignedMemberCount,
      'assignedMemberCount': assignedMemberCount,
      'employeeCode': employeeCode,
    };
  }
}

class TrainerAssignmentModel {
  final int? id;
  final int memberId;
  final int trainerId;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final DateTime? createdAt;

  // Joined
  final String? memberName;
  final String? memberCode;
  final String? trainerName;
  final String? trainerSpecialization;

  TrainerAssignmentModel({
    this.id,
    required this.memberId,
    required this.trainerId,
    required this.startDate,
    this.endDate,
    this.status = 'ACTIVE',
    this.createdAt,
    this.memberName,
    this.memberCode,
    this.trainerName,
    this.trainerSpecialization,
  });

  factory TrainerAssignmentModel.fromMap(Map<String, dynamic> map) {
    return TrainerAssignmentModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      memberId: int.tryParse(map['member_id']?.toString() ?? map['memberId']?.toString() ?? '0') ?? 0,
      trainerId: int.tryParse(map['trainer_id']?.toString() ?? map['trainerId']?.toString() ?? '0') ?? 0,
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date'].toString()) : DateTime.now(),
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'].toString()) : null,
      status: map['status']?.toString() ?? 'ACTIVE',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      memberName: map['member_name']?.toString(),
      memberCode: map['member_code']?.toString(),
      trainerName: map['trainer_name']?.toString(),
      trainerSpecialization: map['specialization']?.toString(),
    );
  }

  factory TrainerAssignmentModel.fromJson(Map<String, dynamic> json) => TrainerAssignmentModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'member_id': memberId,
      'trainer_id': trainerId,
      'start_date': startDate.toIso8601String().split('T').first,
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first,
      'status': status,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'memberId': memberId,
      'trainerId': trainerId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'memberName': memberName,
      'memberCode': memberCode,
      'trainerName': trainerName,
      'trainerSpecialization': trainerSpecialization,
    };
  }
}
