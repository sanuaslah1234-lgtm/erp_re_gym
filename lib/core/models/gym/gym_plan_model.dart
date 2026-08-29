class GymPlanModel {
  final int? id;
  final String name;
  final String? description;
  final int durationDays;
  final double price;
  final double discount;
  final double tax;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GymPlanModel({
    this.id,
    required this.name,
    this.description,
    required this.durationDays,
    required this.price,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.totalAmount,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
  });

  factory GymPlanModel.fromMap(Map<String, dynamic> map) {
    return GymPlanModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      durationDays: int.tryParse(map['duration_days']?.toString() ?? '30') ?? 30,
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(map['discount']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(map['tax']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(map['total_amount']?.toString() ?? '0') ?? 0.0,
      status: map['status']?.toString() ?? 'ACTIVE',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  factory GymPlanModel.fromJson(Map<String, dynamic> json) => GymPlanModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'duration_days': durationDays,
      'price': price,
      'discount': discount,
      'tax': tax,
      'total_amount': totalAmount,
      'status': status,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'durationDays': durationDays,
      'duration_days': durationDays,
      'price': price,
      'discount': discount,
      'tax': tax,
      'totalAmount': totalAmount,
      'total_amount': totalAmount,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  GymPlanModel copyWith({
    int? id,
    String? name,
    String? description,
    int? durationDays,
    double? price,
    double? discount,
    double? tax,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GymPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
