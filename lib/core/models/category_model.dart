class CategoryModel {
  final dynamic id;
  final String name;
  final String? description;
  final String status;
  final int productCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    this.id,
    required this.name,
    this.description,
    this.status = 'active',
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
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
      'description': description,
      'status': status,
      'productCount': productCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
