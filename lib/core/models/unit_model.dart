class UnitModel {
  final dynamic id;
  final String name;
  final String shortSymbol;
  final String status;
  final int productCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UnitModel({
    this.id,
    required this.name,
    required this.shortSymbol,
    this.status = 'active',
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      name: (json['name'] ?? '').toString(),
      shortSymbol: (json['shortSymbol'] ?? json['short_symbol'] ?? json['symbol'] ?? json['code'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      productCount: int.tryParse(json['productCount']?.toString() ?? json['product_count']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortSymbol': shortSymbol,
      'status': status,
      'productCount': productCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
