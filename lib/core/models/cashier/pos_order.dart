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

  factory PosOrderItem.fromJson(Map<String, dynamic> json) {
    return PosOrderItem(
      id: json['id'] as int? ?? 0,
      orderId: json['orderId'] ?? json['order_id'] ?? 0,
      productId: json['productId'] ?? json['product_id'] ?? 0,
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unitPrice: (json['unitPrice'] ?? json['unit_price'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax_amount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0.0).toDouble(),
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

  factory PosOrder.fromJson(Map<String, dynamic> json) {
    return PosOrder(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '',
      customerId: json['customerId'] ?? json['customer_id'],
      customerName: json['customerName'] ?? json['customer_name'],
      cashierId: json['cashierId'] ?? json['cashier_id'] ?? 1,
      cashierName: json['cashierName'] ?? json['cashier_name'],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax_amount'] ?? 0.0).toDouble(),
      grandTotal: (json['grandTotal'] ?? json['grand_total'] ?? 0.0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? json['payment_status'] ?? 'paid',
      orderStatus: json['orderStatus'] ?? json['order_status'] ?? 'paid',
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      amountReceived: (json['amountReceived'] ?? json['amount_received'] ?? 0.0).toDouble(),
      changeAmount: (json['changeAmount'] ?? json['change_amount'] ?? 0.0).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => PosOrderItem.fromJson(i)).toList()
          : [],
      payments: json['payments'] != null
          ? (json['payments'] as List).map((p) => Payment.fromJson(p)).toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
