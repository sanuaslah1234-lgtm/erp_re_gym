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

  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory RefundItemModel.fromJson(Map<String, dynamic> json) {
    return RefundItemModel(
      id: _parseInt(json['id']),
      refundId: _parseInt(json['refundId'] ?? json['refund_id']),
      orderItemId: _parseInt(json['orderItemId'] ?? json['order_item_id']) ?? 0,
      productId: _parseInt(json['productId'] ?? json['product_id']) ?? 0,
      productName: json['productName'] ?? json['product_name'],
      quantity: _parseDouble(json['quantity']),
      refundAmount: _parseDouble(json['refundAmount'] ?? json['refund_amount']),
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

  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: json['id'] as int?,
      refundNumber: json['refundNumber'] ?? json['refund_number'] ?? '',
      orderId: json['orderId'] ?? json['order_id'],
      orderNumber: json['orderNumber'] ?? json['order_number'],
      refundAmount: _parseDouble(json['refundAmount'] ?? json['refund_amount']),
      refundMethod: json['refundMethod'] ?? json['refund_method'] ?? 'Cash',
      reason: json['reason']?.toString(),
      processedBy: _parseInt(json['processedBy'] ?? json['processed_by']) ?? 1,
      processorName: (json['processorName'] ?? json['processor_name'])?.toString(),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => RefundItemModel.fromJson(i is Map<String, dynamic> ? i : Map<String, dynamic>.from(i as Map))).toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
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
