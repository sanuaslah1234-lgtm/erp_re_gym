class Product {
  final dynamic id;
  final String productCode;
  final String? barcode;
  final String name;
  final dynamic categoryId;
  final String? categoryName;
  final dynamic brandId;
  final String? brand;
  final double purchasePrice;
  final double sellingPrice;
  final double taxPercentage;
  final double stockQuantity;
  final String unit;
  final String? imageUrl;
  final bool isActive;

  Product({
    required this.id,
    required this.productCode,
    this.barcode,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brand,
    this.purchasePrice = 0.0,
    required this.sellingPrice,
    this.taxPercentage = 0.0,
    this.stockQuantity = 0.0,
    this.unit = 'pcs',
    this.imageUrl,
    this.isActive = true,
  });

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? defaultVal;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productCode: (json['productCode'] ?? json['product_code'] ?? json['sku'] ?? '').toString(),
      barcode: json['barcode']?.toString() ?? json['sku']?.toString(),
      name: (json['name'] ?? json['product_name'] ?? '').toString(),
      categoryId: json['categoryId'] ?? json['category_id'],
      categoryName: json['categoryName'] ?? json['category_name'],
      brandId: json['brandId'] ?? json['brand_id'],
      brand: json['brand']?.toString() ?? json['brand_name']?.toString(),
      purchasePrice: _parseDouble(json['purchasePrice'] ?? json['purchase_price']),
      sellingPrice: _parseDouble(json['sellingPrice'] ?? json['selling_price']),
      taxPercentage: _parseDouble(json['taxPercentage'] ?? json['tax_percentage']),
      stockQuantity: _parseDouble(json['stockQuantity'] ?? json['stock_quantity'] ?? json['stock']),
      unit: (json['unit'] ?? 'pcs').toString(),
      imageUrl: json['imageUrl'] ?? json['image_url'],
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
      'brandId': brandId,
      'brand': brand,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'taxPercentage': taxPercentage,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
