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

  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['orderId'] ?? json['order_id']),
      productId: _parseInt(json['productId'] ?? json['product_id']) ?? 0,
      productName: (json['productName'] ?? json['product_name'] ?? '').toString(),
      quantity: _parseDouble(json['quantity']),
      unitPrice: _parseDouble(json['unitPrice'] ?? json['unit_price']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax_amount']),
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
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
