import 'package:erp_software/core/models/cashier/order_item_model.dart';
import 'package:erp_software/core/models/cashier/payment_model.dart';

class PosOrderModel {
  final int? id;
  final String orderNumber;
  final int? customerId;
  final String? customerName;
  final int cashierId;
  final String? cashierName;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double grandTotal;
  final String paymentStatus; // 'pending', 'paid', 'cancelled', 'refunded', 'partially_refunded'
  final String orderStatus; // 'paid', 'pending', 'cancelled'
  final String? paymentMethod;
  final double amountReceived;
  final double changeAmount;
  final List<OrderItemModel> items;
  final List<PaymentModel> payments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PosOrderModel({
    this.id,
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
    this.updatedAt,
  });

  factory PosOrderModel.fromJson(Map<String, dynamic> json) {
    return PosOrderModel(
      id: json['id'] as int?,
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
          ? (json['items'] as List).map((i) => OrderItemModel.fromJson(i)).toList()
          : [],
      payments: json['payments'] != null
          ? (json['payments'] as List).map((p) => PaymentModel.fromJson(p)).toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'grandTotal': grandTotal,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'amountReceived': amountReceived,
      'changeAmount': changeAmount,
      'items': items.map((i) => i.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
