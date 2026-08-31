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
    bool parseActive(dynamic val) {
      if (val == null) return true;
      if (val is bool) return val;
      final str = val.toString().toUpperCase();
      return str == 'ACTIVE' || str == 'TRUE' || str == '1';
    }

    return WarehouseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      isActive: parseActive(json['is_active'] ?? json['isActive'] ?? json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'address': address,
    'phone': phone,
    'is_active': isActive,
    'isActive': isActive,
    'status': isActive ? 'ACTIVE' : 'INACTIVE',
  };
}