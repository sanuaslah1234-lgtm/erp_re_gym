class GymMemberModel {
  final int? id;
  final String memberCode;
  final String? customerId;
  final String name;
  final String phone;
  final String? email;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? emergencyContact;
  final DateTime joinDate;
  final String status;
  final String? photo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined / Helper attributes
  final String? currentPlanName;
  final DateTime? currentMembershipEndDate;
  final int? daysRemaining;
  final String? assignedTrainerName;
  final int? assignedTrainerId;
  final double? totalPaid;
  final int? totalAttendanceCount;

  GymMemberModel({
    this.id,
    required this.memberCode,
    this.customerId,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
    required this.joinDate,
    this.status = 'ACTIVE',
    this.photo,
    this.createdAt,
    this.updatedAt,
    this.currentPlanName,
    this.currentMembershipEndDate,
    this.daysRemaining,
    this.assignedTrainerName,
    this.assignedTrainerId,
    this.totalPaid,
    this.totalAttendanceCount,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isExpired => status.toUpperCase() == 'EXPIRED' || (daysRemaining != null && daysRemaining! < 0);
  bool get isExpiringSoon => daysRemaining != null && daysRemaining! >= 0 && daysRemaining! <= 7;

  factory GymMemberModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    final join = parseDate(map['join_date'] ?? map['joinDate']) ?? DateTime.now();
    final memberDob = parseDate(map['date_of_birth'] ?? map['dateOfBirth']);
    final membershipEnd = parseDate(map['current_membership_end_date'] ?? map['currentMembershipEndDate'] ?? map['end_date']);

    int? remaining;
    if (membershipEnd != null) {
      remaining = membershipEnd.difference(DateTime.now()).inDays;
    } else if (map['days_remaining'] != null) {
      remaining = int.tryParse(map['days_remaining'].toString());
    }

    return GymMemberModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      memberCode: map['member_code']?.toString() ?? map['memberCode']?.toString() ?? '',
      customerId: map['customer_id']?.toString() ?? map['customerId']?.toString(),
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString(),
      gender: map['gender']?.toString(),
      dateOfBirth: memberDob,
      address: map['address']?.toString(),
      emergencyContact: map['emergency_contact']?.toString() ?? map['emergencyContact']?.toString(),
      joinDate: join,
      status: map['status']?.toString() ?? 'ACTIVE',
      photo: map['photo']?.toString(),
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      currentPlanName: map['current_plan_name']?.toString() ?? map['plan_name']?.toString() ?? map['currentPlanName']?.toString(),
      currentMembershipEndDate: membershipEnd,
      daysRemaining: remaining,
      assignedTrainerName: map['assigned_trainer_name']?.toString() ?? map['trainer_name']?.toString() ?? map['assignedTrainerName']?.toString(),
      assignedTrainerId: map['assigned_trainer_id'] != null
          ? int.tryParse(map['assigned_trainer_id'].toString())
          : (map['trainer_id'] != null ? int.tryParse(map['trainer_id'].toString()) : null),
      totalPaid: double.tryParse(map['total_paid']?.toString() ?? '0') ?? 0.0,
      totalAttendanceCount: int.tryParse(map['total_attendance_count']?.toString() ?? map['attendance_count']?.toString() ?? '0') ?? 0,
    );
  }

  factory GymMemberModel.fromJson(Map<String, dynamic> json) => GymMemberModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'member_code': memberCode,
      if (customerId != null) 'customer_id': customerId,
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      if (address != null) 'address': address,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      'join_date': joinDate.toIso8601String().split('T').first,
      'status': status,
      if (photo != null) 'photo': photo,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'memberCode': memberCode,
      'member_code': memberCode,
      if (customerId != null) 'customerId': customerId,
      if (customerId != null) 'customer_id': customerId,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'emergencyContact': emergencyContact,
      'emergency_contact': emergencyContact,
      'joinDate': joinDate.toIso8601String(),
      'join_date': joinDate.toIso8601String(),
      'status': status,
      'photo': photo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'currentPlanName': currentPlanName,
      'currentMembershipEndDate': currentMembershipEndDate?.toIso8601String(),
      'daysRemaining': daysRemaining,
      'assignedTrainerName': assignedTrainerName,
      'assignedTrainerId': assignedTrainerId,
      'totalPaid': totalPaid,
      'totalAttendanceCount': totalAttendanceCount,
    };
  }

  GymMemberModel copyWith({
    int? id,
    String? memberCode,
    String? customerId,
    String? name,
    String? phone,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? emergencyContact,
    DateTime? joinDate,
    String? status,
    String? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentPlanName,
    DateTime? currentMembershipEndDate,
    int? daysRemaining,
    String? assignedTrainerName,
    int? assignedTrainerId,
    double? totalPaid,
    int? totalAttendanceCount,
  }) {
    return GymMemberModel(
      id: id ?? this.id,
      memberCode: memberCode ?? this.memberCode,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentPlanName: currentPlanName ?? this.currentPlanName,
      currentMembershipEndDate: currentMembershipEndDate ?? this.currentMembershipEndDate,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      assignedTrainerName: assignedTrainerName ?? this.assignedTrainerName,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
      totalPaid: totalPaid ?? this.totalPaid,
      totalAttendanceCount: totalAttendanceCount ?? this.totalAttendanceCount,
    );
  }
}
