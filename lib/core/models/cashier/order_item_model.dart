class OrderItemModel {
  final int? id;
  final int? orderId;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;

  OrderItemModel({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      orderId: json['orderId'] ?? json['order_id'],
      productId: json['productId'] ?? json['product_id'],
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unitPrice: (json['unitPrice'] ?? json['unit_price'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax_amount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
    };
  }
}
