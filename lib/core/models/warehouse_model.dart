class WarehouseModel {
  final String id;
  final String name;
  final String? code;
  final String? address;
  final String? phone;
  final bool isActive;

  const WarehouseModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.phone,
    this.isActive = true,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'address': address,
    'phone': phone,
    'is_active': isActive,
  };
}