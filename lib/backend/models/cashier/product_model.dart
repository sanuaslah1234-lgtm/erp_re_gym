class ProductModel {
  final int? id;
  final String productCode;
  final String? barcode;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final int? supplierId;
  final String? supplierName;
  final String? brand;
  final double purchasePrice;
  final double sellingPrice;
  final double taxPercentage;
  final double openingStock;
  final double stockQuantity;
  final double minimumStock;
  final String unit;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    required this.productCode,
    this.barcode,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.supplierId,
    this.supplierName,
    this.brand,
    this.purchasePrice = 0.0,
    required this.sellingPrice,
    this.taxPercentage = 0.0,
    this.openingStock = 0.0,
    this.stockQuantity = 0.0,
    this.minimumStock = 5.0,
    this.unit = 'pcs',
    this.imageUrl,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isLowStock => stockQuantity <= minimumStock;

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? defaultVal;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      productCode: (json['productCode'] ?? json['product_code'] ?? '').toString(),
      barcode: json['barcode']?.toString(),
      name: (json['name'] ?? '').toString(),
      categoryId: json['categoryId'] ?? json['category_id'],
      categoryName: json['categoryName'] ?? json['category_name'],
      supplierId: json['supplierId'] ?? json['supplier_id'],
      supplierName: json['supplierName'] ?? json['supplier_name'],
      brand: json['brand']?.toString(),
      purchasePrice: _parseDouble(json['purchasePrice'] ?? json['purchase_price']),
      sellingPrice: _parseDouble(json['sellingPrice'] ?? json['selling_price']),
      taxPercentage: _parseDouble(json['taxPercentage'] ?? json['tax_percentage']),
      openingStock: _parseDouble(json['openingStock'] ?? json['opening_stock']),
      stockQuantity: _parseDouble(json['stockQuantity'] ?? json['stock_quantity']),
      minimumStock: _parseDouble(json['minimumStock'] ?? json['minimum_stock'], 5.0),
      unit: (json['unit'] ?? 'pcs').toString(),
      imageUrl: json['imageUrl'] ?? json['image_url'],
      description: json['description']?.toString(),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'barcode': barcode,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'brand': brand,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'taxPercentage': taxPercentage,
      'openingStock': openingStock,
      'stockQuantity': stockQuantity,
      'minimumStock': minimumStock,
      'unit': unit,
      'imageUrl': imageUrl,
      'description': description,
      'isActive': isActive,
      'isLowStock': isLowStock,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
