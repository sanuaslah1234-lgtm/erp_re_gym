class GymScheduleModel {
  final int? id;
  final int? trainerId;
  final String title;
  final String? description;
  final String startTime;
  final String endTime;
  final DateTime date;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined
  final String? trainerName;
  final String? trainerSpecialization;

  GymScheduleModel({
    this.id,
    this.trainerId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.date,
    this.status = 'SCHEDULED',
    this.createdAt,
    this.updatedAt,
    this.trainerName,
    this.trainerSpecialization,
  });

  factory GymScheduleModel.fromMap(Map<String, dynamic> map) {
    DateTime parseD(dynamic v, [DateTime? fallback]) {
      if (v == null) return fallback ?? DateTime.now();
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    return GymScheduleModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      trainerId: map['trainer_id'] != null ? int.tryParse(map['trainer_id'].toString()) : (map['trainerId'] != null ? int.tryParse(map['trainerId'].toString()) : null),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      startTime: map['start_time']?.toString() ?? map['startTime']?.toString() ?? '08:00 AM',
      endTime: map['end_time']?.toString() ?? map['endTime']?.toString() ?? '09:00 AM',
      date: parseD(map['date']),
      status: map['status']?.toString() ?? 'SCHEDULED',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
      trainerName: map['trainer_name']?.toString() ?? map['trainerName']?.toString(),
      trainerSpecialization: map['specialization']?.toString() ?? map['trainerSpecialization']?.toString(),
    );
  }

  factory GymScheduleModel.fromJson(Map<String, dynamic> json) => GymScheduleModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (trainerId != null) 'trainer_id': trainerId,
      'title': title,
      if (description != null) 'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'date': date.toIso8601String().split('T').first,
      'status': status,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'trainerId': trainerId,
      'trainer_id': trainerId,
      'title': title,
      'description': description,
      'startTime': startTime,
      'start_time': startTime,
      'endTime': endTime,
      'end_time': endTime,
      'date': date.toIso8601String(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'trainerName': trainerName,
      'trainerSpecialization': trainerSpecialization,
    };
  }
}
