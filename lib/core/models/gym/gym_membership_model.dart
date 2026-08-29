class GymMembershipModel {
  final int? id;
  final int memberId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final double discount;
  final double tax;
  final double finalAmount;
  final String status;
  final bool autoRenew;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields
  final String? memberName;
  final String? memberCode;
  final String? memberPhone;
  final String? planName;
  final int? durationDays;
  final String? paymentStatus;
  final int? invoiceId;

  GymMembershipModel({
    this.id,
    required this.memberId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.finalAmount,
    this.status = 'ACTIVE',
    this.autoRenew = false,
    this.createdAt,
    this.updatedAt,
    this.memberName,
    this.memberCode,
    this.memberPhone,
    this.planName,
    this.durationDays,
    this.paymentStatus,
    this.invoiceId,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isExpired => status.toUpperCase() == 'EXPIRED' || DateTime.now().isAfter(endDate);
  int get daysLeft => endDate.difference(DateTime.now()).inDays;

  factory GymMembershipModel.fromMap(Map<String, dynamic> map) {
    DateTime parseD(dynamic v, [DateTime? fallback]) {
      if (v == null) return fallback ?? DateTime.now();
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    return GymMembershipModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      memberId: int.tryParse(map['member_id']?.toString() ?? map['memberId']?.toString() ?? '0') ?? 0,
      planId: int.tryParse(map['plan_id']?.toString() ?? map['planId']?.toString() ?? '0') ?? 0,
      startDate: parseD(map['start_date'] ?? map['startDate']),
      endDate: parseD(map['end_date'] ?? map['endDate']),
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(map['discount']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(map['tax']?.toString() ?? '0') ?? 0.0,
      finalAmount: double.tryParse(map['final_amount']?.toString() ?? map['finalAmount']?.toString() ?? '0') ?? 0.0,
      status: map['status']?.toString() ?? 'ACTIVE',
      autoRenew: map['auto_renew'] == true || map['auto_renew']?.toString() == 'true' || map['autoRenew'] == true,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
      memberName: map['member_name']?.toString() ?? map['memberName']?.toString(),
      memberCode: map['member_code']?.toString() ?? map['memberCode']?.toString(),
      memberPhone: map['member_phone']?.toString() ?? map['phone']?.toString(),
      planName: map['plan_name']?.toString() ?? map['planName']?.toString(),
      durationDays: map['duration_days'] != null ? int.tryParse(map['duration_days'].toString()) : null,
      paymentStatus: map['payment_status']?.toString() ?? map['paymentStatus']?.toString(),
      invoiceId: map['invoice_id'] != null ? int.tryParse(map['invoice_id'].toString()) : null,
    );
  }

  factory GymMembershipModel.fromJson(Map<String, dynamic> json) => GymMembershipModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'member_id': memberId,
      'plan_id': planId,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'amount': amount,
      'discount': discount,
      'tax': tax,
      'final_amount': finalAmount,
      'status': status,
      'auto_renew': autoRenew,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'memberId': memberId,
      'member_id': memberId,
      'planId': planId,
      'plan_id': planId,
      'startDate': startDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'amount': amount,
      'discount': discount,
      'tax': tax,
      'finalAmount': finalAmount,
      'final_amount': finalAmount,
      'status': status,
      'autoRenew': autoRenew,
      'auto_renew': autoRenew,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'memberName': memberName,
      'memberCode': memberCode,
      'memberPhone': memberPhone,
      'planName': planName,
      'durationDays': durationDays,
      'paymentStatus': paymentStatus,
      'invoiceId': invoiceId,
    };
  }
}
