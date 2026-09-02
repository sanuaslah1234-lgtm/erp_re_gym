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

  static int _parseInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? def;
  }

  factory PosOrderItem.fromJson(Map<String, dynamic> json) {
    return PosOrderItem(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['orderId'] ?? json['order_id']),
      productId: _parseInt(json['productId'] ?? json['product_id']),
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: double.tryParse((json['quantity'] ?? '0').toString()) ?? 0.0,
      unitPrice: double.tryParse((json['unitPrice'] ?? json['unit_price'] ?? '0').toString()) ?? 0.0,
      discountAmount: double.tryParse((json['discountAmount'] ?? json['discount_amount'] ?? '0').toString()) ?? 0.0,
      taxAmount: double.tryParse((json['taxAmount'] ?? json['tax_amount'] ?? '0').toString()) ?? 0.0,
      totalAmount: double.tryParse((json['totalAmount'] ?? json['total_amount'] ?? '0').toString()) ?? 0.0,
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

  static int _parseInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? def;
  }

  factory PosOrder.fromJson(Map<String, dynamic> json) {
    return PosOrder(
      id: _parseInt(json['id']),
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '',
      customerId: json['customerId'] ?? json['customer_id'],
      customerName: json['customerName'] ?? json['customer_name'],
      cashierId: _parseInt(json['cashierId'] ?? json['cashier_id'], 1),
      cashierName: json['cashierName'] ?? json['cashier_name'],
      subtotal: double.tryParse((json['subtotal'] ?? '0').toString()) ?? 0.0,
      discountAmount: double.tryParse((json['discountAmount'] ?? json['discount_amount'] ?? '0').toString()) ?? 0.0,
      taxAmount: double.tryParse((json['taxAmount'] ?? json['tax_amount'] ?? '0').toString()) ?? 0.0,
      grandTotal: double.tryParse((json['grandTotal'] ?? json['grand_total'] ?? '0').toString()) ?? 0.0,
      paymentStatus: json['paymentStatus'] ?? json['payment_status'] ?? 'paid',
      orderStatus: json['orderStatus'] ?? json['order_status'] ?? 'paid',
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      amountReceived: double.tryParse((json['amountReceived'] ?? json['amount_received'] ?? '0').toString()) ?? 0.0,
      changeAmount: double.tryParse((json['changeAmount'] ?? json['change_amount'] ?? '0').toString()) ?? 0.0,
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
