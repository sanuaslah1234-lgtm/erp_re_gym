class GymPaymentModel {
  final int? id;
  final int memberId;
  final int? membershipId;
  final String? invoiceId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? referenceNumber;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields
  final String? memberName;
  final String? memberCode;
  final String? memberPhone;
  final String? planName;
  final String? invoiceNumber;

  GymPaymentModel({
    this.id,
    required this.memberId,
    this.membershipId,
    this.invoiceId,
    required this.amount,
    this.paymentMethod = 'CASH',
    required this.paymentDate,
    this.referenceNumber,
    this.status = 'PAID',
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.memberName,
    this.memberCode,
    this.memberPhone,
    this.planName,
    this.invoiceNumber,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';
  bool get isPending => status.toUpperCase() == 'PENDING';

  factory GymPaymentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseD(dynamic v, [DateTime? fallback]) {
      if (v == null) return fallback ?? DateTime.now();
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    return GymPaymentModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      memberId: int.tryParse(map['member_id']?.toString() ?? map['memberId']?.toString() ?? '0') ?? 0,
      membershipId: map['membership_id'] != null ? int.tryParse(map['membership_id'].toString()) : (map['membershipId'] != null ? int.tryParse(map['membershipId'].toString()) : null),
      invoiceId: map['invoice_id']?.toString() ?? map['invoiceId']?.toString(),
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: map['payment_method']?.toString() ?? map['paymentMethod']?.toString() ?? 'CASH',
      paymentDate: parseD(map['payment_date'] ?? map['paymentDate']),
      referenceNumber: map['reference_number']?.toString() ?? map['referenceNumber']?.toString(),
      status: map['status']?.toString() ?? 'PAID',
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
      memberName: map['member_name']?.toString() ?? map['memberName']?.toString(),
      memberCode: map['member_code']?.toString() ?? map['memberCode']?.toString(),
      memberPhone: map['member_phone']?.toString() ?? map['phone']?.toString(),
      planName: map['plan_name']?.toString() ?? map['planName']?.toString(),
      invoiceNumber: map['invoice_number']?.toString() ?? map['invoiceNumber']?.toString(),
    );
  }

  factory GymPaymentModel.fromJson(Map<String, dynamic> json) => GymPaymentModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'member_id': memberId,
      if (membershipId != null) 'membership_id': membershipId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      if (referenceNumber != null) 'reference_number': referenceNumber,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'memberId': memberId,
      'member_id': memberId,
      'membershipId': membershipId,
      'membership_id': membershipId,
      'invoiceId': invoiceId,
      'invoice_id': invoiceId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'payment_method': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'payment_date': paymentDate.toIso8601String(),
      'referenceNumber': referenceNumber,
      'reference_number': referenceNumber,
      'status': status,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'memberName': memberName,
      'memberCode': memberCode,
      'memberPhone': memberPhone,
      'planName': planName,
      'invoiceNumber': invoiceNumber,
    };
  }
}
