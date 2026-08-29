class RefundItem {
  final int id;
  final int refundId;
  final int orderItemId;
  final int productId;
  final String? productName;
  final double quantity;
  final double refundAmount;

  RefundItem({
    required this.id,
    required this.refundId,
    required this.orderItemId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.refundAmount,
  });

  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
      id: json['id'] as int? ?? 0,
      refundId: json['refundId'] ?? json['refund_id'] ?? 0,
      orderItemId: json['orderItemId'] ?? json['order_item_id'] ?? 0,
      productId: json['productId'] ?? json['product_id'] ?? 0,
      productName: json['productName'] ?? json['product_name'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      refundAmount: (json['refundAmount'] ?? json['refund_amount'] ?? 0.0).toDouble(),
    );
  }
}

class Refund {
  final int id;
  final String refundNumber;
  final int orderId;
  final String? orderNumber;
  final double refundAmount;
  final String refundMethod;
  final String? reason;
  final int processedBy;
  final String? processorName;
  final List<RefundItem> items;
  final DateTime? createdAt;

  Refund({
    required this.id,
    required this.refundNumber,
    required this.orderId,
    this.orderNumber,
    required this.refundAmount,
    required this.refundMethod,
    this.reason,
    required this.processedBy,
    this.processorName,
    this.items = const [],
    this.createdAt,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'] as int,
      refundNumber: json['refundNumber'] ?? json['refund_number'] ?? '',
      orderId: json['orderId'] ?? json['order_id'] ?? 0,
      orderNumber: json['orderNumber'] ?? json['order_number'],
      refundAmount: (json['refundAmount'] ?? json['refund_amount'] ?? 0.0).toDouble(),
      refundMethod: json['refundMethod'] ?? json['refund_method'] ?? 'Cash',
      reason: json['reason']?.toString(),
      processedBy: json['processedBy'] ?? json['processed_by'] ?? 1,
      processorName: json['processorName'] ?? json['processor_name'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => RefundItem.fromJson(i)).toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
