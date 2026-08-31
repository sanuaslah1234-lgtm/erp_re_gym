import 'package:erp_software/core/models/cashier/payment.dart';

class PosOrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;

  PosOrderItem({
    required this.id,
    required this.orderId,
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

  factory PosOrderItem.fromJson(Map<String, dynamic> json) {
    return PosOrderItem(
      id: _parseInt(json['id']) ?? 0,
      orderId: _parseInt(json['orderId'] ?? json['order_id']) ?? 0,
      productId: _parseInt(json['productId'] ?? json['product_id']) ?? 0,
      productName: (json['productName'] ?? json['product_name'] ?? '').toString(),
      quantity: _parseDouble(json['quantity']),
      unitPrice: _parseDouble(json['unitPrice'] ?? json['unit_price']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax_amount']),
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
    );
  }
}

class PosOrder {
  final int id;
  final String orderNumber;
  final int? customerId;
  final String? customerName;
  final int cashierId;
  final String? cashierName;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double grandTotal;
  final String paymentStatus;
  final String orderStatus;
  final String? paymentMethod;
  final double amountReceived;
  final double changeAmount;
  final List<PosOrderItem> items;
  final List<Payment> payments;
  final DateTime? createdAt;

  PosOrder({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    required this.cashierId,
    this.cashierName,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.grandTotal,
    this.paymentStatus = 'paid',
    this.orderStatus = 'paid',
    this.paymentMethod,
    this.amountReceived = 0.0,
    this.changeAmount = 0.0,
    this.items = const [],
    this.payments = const [],
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

  factory PosOrder.fromJson(Map<String, dynamic> json) {
    return PosOrder(
      id: _parseInt(json['id']) ?? 0,
      orderNumber: (json['orderNumber'] ?? json['order_number'] ?? '').toString(),
      customerId: _parseInt(json['customerId'] ?? json['customer_id']),
      customerName: (json['customerName'] ?? json['customer_name'])?.toString(),
      cashierId: _parseInt(json['cashierId'] ?? json['cashier_id']) ?? 1,
      cashierName: (json['cashierName'] ?? json['cashier_name'])?.toString(),
      subtotal: _parseDouble(json['subtotal']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax_amount']),
      grandTotal: _parseDouble(json['grandTotal'] ?? json['grand_total']),
      paymentStatus: (json['paymentStatus'] ?? json['payment_status'] ?? 'paid').toString(),
      orderStatus: (json['orderStatus'] ?? json['order_status'] ?? 'paid').toString(),
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'])?.toString(),
      amountReceived: _parseDouble(json['amountReceived'] ?? json['amount_received']),
      changeAmount: _parseDouble(json['changeAmount'] ?? json['change_amount']),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => PosOrderItem.fromJson(i is Map<String, dynamic> ? i : Map<String, dynamic>.from(i as Map))).toList()
          : [],
      payments: json['payments'] != null
          ? (json['payments'] as List).map((p) => Payment.fromJson(p is Map<String, dynamic> ? p : Map<String, dynamic>.from(p as Map))).toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
    );
  }
}
