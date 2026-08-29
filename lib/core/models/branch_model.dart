class BranchModel {
  final int? id;
  final String code;
  final String name;
  final String address;
  final String city;
  final String state;
  final String phone;
  final String email;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BranchModel({
    this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    required this.email,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel.fromMap(json);
  factory BranchModel.fromMap(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int?,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  /// Used for POST/PUT bodies — backend validates these exact keys.
  Map<String, dynamic> toJson() => toRequestJson();
  Map<String, dynamic> toRequestJson() {
    return {
      'code': code,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      'email': email,
      'is_active': isActive,
    };
  }

  BranchModel copyWith({
    int? id,
    String? code,
    String? name,
    String? address,
    String? city,
    String? state,
    String? phone,
    String? email,
    bool? isActive,
  }) {
    return BranchModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}