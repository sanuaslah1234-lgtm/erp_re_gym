class CartItemModel {
  final int productId;
  final String productCode;
  final String productName;
  final String? barcode;
  final double quantity;
  final double unitPrice;
  final double discount; // Percentage discount (e.g., 10.0 for 10%)
  final double tax; // Percentage tax (e.g., 5.0 for 5%)
  final double discountAmount;
  final double taxAmount;
  final double total;

  CartItemModel({
    required this.productId,
    required this.productCode,
    required this.productName,
    this.barcode,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
  });

  /// Factory calculator method according to ERP requirements:
  /// subtotal = quantity * unitPrice
  /// discountAmount = subtotal * discount / 100
  /// taxableAmount = subtotal - discountAmount
  /// taxAmount = taxableAmount * tax / 100
  /// total = taxableAmount + taxAmount
  factory CartItemModel.calculate({
    required int productId,
    required String productCode,
    required String productName,
    String? barcode,
    required double quantity,
    required double unitPrice,
    double discount = 0.0,
    double tax = 0.0,
  }) {
    final subtotal = quantity * unitPrice;
    final discountAmount = subtotal * (discount / 100.0);
    final taxableAmount = subtotal - discountAmount;
    final taxAmount = taxableAmount * (tax / 100.0);
    final total = taxableAmount + taxAmount;

    return CartItemModel(
      productId: productId,
      productCode: productCode,
      productName: productName,
      barcode: barcode,
      quantity: quantity,
      unitPrice: unitPrice,
      discount: discount,
      tax: tax,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      total: total,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? json['product_id'],
      productCode: json['productCode'] ?? json['product_code'] ?? '',
      productName: json['productName'] ?? json['product_name'] ?? '',
      barcode: json['barcode']?.toString(),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unitPrice: (json['unitPrice'] ?? json['unit_price'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax_amount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? json['total_amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productCode': productCode,
      'productName': productName,
      'barcode': barcode,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
      'tax': tax,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'total': total,
    };
  }
}
