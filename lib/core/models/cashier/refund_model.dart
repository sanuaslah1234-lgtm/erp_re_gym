class RefundItemModel {
  final int? id;
  final int? refundId;
  final int orderItemId;
  final int productId;
  final String? productName;
  final double quantity;
  final double refundAmount;

  RefundItemModel({
    this.id,
    this.refundId,
    required this.orderItemId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.refundAmount,
  });

  factory RefundItemModel.fromJson(Map<String, dynamic> json) {
    return RefundItemModel(
      id: json['id'] as int?,
      refundId: json['refundId'] ?? json['refund_id'],
      orderItemId: json['orderItemId'] ?? json['order_item_id'],
      productId: json['productId'] ?? json['product_id'],
      productName: json['productName'] ?? json['product_name'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      refundAmount: (json['refundAmount'] ?? json['refund_amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refundId': refundId,
      'orderItemId': orderItemId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'refundAmount': refundAmount,
    };
  }
}

class RefundModel {
  final int? id;
  final String refundNumber;
  final int orderId;
  final String? orderNumber;
  final double refundAmount;
  final String refundMethod; // 'Cash', 'Card', 'UPI'
  final String? reason;
  final int processedBy;
  final String? processorName;
  final List<RefundItemModel> items;
  final DateTime? createdAt;

  RefundModel({
    this.id,
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

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: json['id'] as int?,
      refundNumber: json['refundNumber'] ?? json['refund_number'] ?? '',
      orderId: json['orderId'] ?? json['order_id'],
      orderNumber: json['orderNumber'] ?? json['order_number'],
      refundAmount: (json['refundAmount'] ?? json['refund_amount'] ?? 0.0).toDouble(),
      refundMethod: json['refundMethod'] ?? json['refund_method'] ?? 'Cash',
      reason: json['reason']?.toString(),
      processedBy: json['processedBy'] ?? json['processed_by'] ?? 1,
      processorName: json['processorName'] ?? json['processor_name'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => RefundItemModel.fromJson(i)).toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refundNumber': refundNumber,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'refundAmount': refundAmount,
      'refundMethod': refundMethod,
      'reason': reason,
      'processedBy': processedBy,
      'processorName': processorName,
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
