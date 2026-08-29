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
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : null,
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : null,
      isActive: map['is_active'] == null ? true : map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branchId': branchId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'loyaltyId': loyaltyId,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}