class Product {
  final int id;
  final String productCode;
  final String? barcode;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final double purchasePrice;
  final double sellingPrice;
  final double taxPercentage;
  final double stockQuantity;
  final String unit;
  final bool isActive;

  Product({
    required this.id,
    required this.productCode,
    this.barcode,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.purchasePrice = 0.0,
    required this.sellingPrice,
    this.taxPercentage = 0.0,
    this.stockQuantity = 0.0,
    this.unit = 'pcs',
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      productCode: json['productCode'] ?? json['product_code'] ?? '',
      barcode: json['barcode']?.toString(),
      name: json['name']?.toString() ?? '',
      categoryId: json['categoryId'] ?? json['category_id'],
      categoryName: json['categoryName'] ?? json['category_name'],
      purchasePrice: (json['purchasePrice'] ?? json['purchase_price'] ?? 0.0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? json['selling_price'] ?? 0.0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? json['tax_percentage'] ?? 0.0).toDouble(),
      stockQuantity: (json['stockQuantity'] ?? json['stock_quantity'] ?? 0.0).toDouble(),
      unit: json['unit']?.toString() ?? 'pcs',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
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
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'taxPercentage': taxPercentage,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'isActive': isActive,
    };
  }
}
