class CustomerModel {
  final String? id;
  final String? branchId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? loyaltyId;
  final double creditLimit;
  final double currentBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  CustomerModel({
    this.id,
    this.branchId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.loyaltyId,
    this.creditLimit = 0.0,
    this.currentBalance = 0.0,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel.fromMap(json);
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id']?.toString(),
      branchId: map['branch_id']?.toString(),
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString(),
      address: map['address']?.toString(),
      loyaltyId: map['loyalty_id']?.toString(),
      creditLimit: double.tryParse(
            map['credit_limit']?.toString() ?? '0',
          ) ??
          0.0,
      currentBalance: double.tryParse(
            map['current_balance']?.toString() ?? '0',
          ) ??
          0.0,
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
      isActive: map['is_active'] == null ? true : map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branch_id': branchId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'loyalty_id': loyaltyId,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}