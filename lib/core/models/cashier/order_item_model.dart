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
      id: int.tryParse(json['id'].toString()),
      orderId: int.tryParse((json['orderId'] ?? json['order_id'] ?? '').toString()),
      productId: int.tryParse((json['productId'] ?? json['product_id'] ?? '0').toString()) ?? 0,
      productName: (json['productName'] ?? json['product_name'] ?? '').toString(),
      quantity: double.tryParse((json['quantity'] ?? '0').toString()) ?? 0.0,
      unitPrice: double.tryParse((json['unitPrice'] ?? json['unit_price'] ?? '0').toString()) ?? 0.0,
      discountAmount: double.tryParse((json['discountAmount'] ?? json['discount_amount'] ?? '0').toString()) ?? 0.0,
      taxAmount: double.tryParse((json['taxAmount'] ?? json['tax_amount'] ?? '0').toString()) ?? 0.0,
      totalAmount: double.tryParse((json['totalAmount'] ?? json['total_amount'] ?? '0').toString()) ?? 0.0,
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
