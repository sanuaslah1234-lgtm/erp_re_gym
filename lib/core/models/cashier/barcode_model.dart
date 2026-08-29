class BarcodeModel {
  final int? id;
  final int productId;
  final String? productName;
  final String? productCode;
  final double? sellingPrice;
  final String barcode;
  final int labelQuantity;
  final int? createdBy;
  final DateTime? createdAt;

  BarcodeModel({
    this.id,
    required this.productId,
    this.productName,
    this.productCode,
    this.sellingPrice,
    required this.barcode,
    this.labelQuantity = 1,
    this.createdBy,
    this.createdAt,
  });

  factory BarcodeModel.fromJson(Map<String, dynamic> json) {
    return BarcodeModel(
      id: json['id'] as int?,
      productId: json['productId'] ?? json['product_id'],
      productName: json['productName'] ?? json['product_name'],
      productCode: json['productCode'] ?? json['product_code'],
      sellingPrice: json['sellingPrice'] != null ? (json['sellingPrice']).toDouble() : (json['selling_price'] != null ? (json['selling_price']).toDouble() : null),
      barcode: json['barcode']?.toString() ?? '',
      labelQuantity: json['labelQuantity'] ?? json['label_quantity'] ?? 1,
      createdBy: json['createdBy'] ?? json['created_by'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'sellingPrice': sellingPrice,
      'barcode': barcode,
      'labelQuantity': labelQuantity,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
