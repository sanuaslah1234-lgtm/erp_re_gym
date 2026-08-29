class GymAttendanceModel {
  final int? id;
  final int memberId;
  final DateTime attendanceDate;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String status;
  final DateTime? createdAt;

  // Joined fields
  final String? memberName;
  final String? memberCode;
  final String? memberPhone;
  final String? planName;
  final String? photo;

  GymAttendanceModel({
    this.id,
    required this.memberId,
    required this.attendanceDate,
    required this.checkIn,
    this.checkOut,
    this.status = 'PRESENT',
    this.createdAt,
    this.memberName,
    this.memberCode,
    this.memberPhone,
    this.planName,
    this.photo,
  });

  Duration? get duration {
    if (checkOut == null) return null;
    return checkOut!.difference(checkIn);
  }

  String get durationString {
    final d = duration;
    if (d == null) return 'In Progress';
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  factory GymAttendanceModel.fromMap(Map<String, dynamic> map) {
    DateTime parseD(dynamic v, [DateTime? fallback]) {
      if (v == null) return fallback ?? DateTime.now();
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    return GymAttendanceModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      memberId: int.tryParse(map['member_id']?.toString() ?? map['memberId']?.toString() ?? '0') ?? 0,
      attendanceDate: parseD(map['attendance_date'] ?? map['attendanceDate']),
      checkIn: parseD(map['check_in'] ?? map['checkIn']),
      checkOut: map['check_out'] != null ? DateTime.tryParse(map['check_out'].toString()) : (map['checkOut'] != null ? DateTime.tryParse(map['checkOut'].toString()) : null),
      status: map['status']?.toString() ?? 'PRESENT',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      memberName: map['member_name']?.toString() ?? map['name']?.toString() ?? map['memberName']?.toString(),
      memberCode: map['member_code']?.toString() ?? map['memberCode']?.toString(),
      memberPhone: map['member_phone']?.toString() ?? map['phone']?.toString(),
      planName: map['plan_name']?.toString() ?? map['planName']?.toString(),
      photo: map['photo']?.toString(),
    );
  }

  factory GymAttendanceModel.fromJson(Map<String, dynamic> json) => GymAttendanceModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'member_id': memberId,
      'attendance_date': attendanceDate.toIso8601String().split('T').first,
      'check_in': checkIn.toIso8601String(),
      if (checkOut != null) 'check_out': checkOut!.toIso8601String(),
      'status': status,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'memberId': memberId,
      'attendanceDate': attendanceDate.toIso8601String(),
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'memberName': memberName,
      'memberCode': memberCode,
      'memberPhone': memberPhone,
      'planName': planName,
      'photo': photo,
      'duration': durationString,
    };
  }
}
