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
      id: int.tryParse(json['id'].toString()),
      orderNumber: json['orderNumber']?.toString() ?? json['order_number']?.toString() ?? '',
      customerId: int.tryParse((json['customerId'] ?? json['customer_id'] ?? '').toString()),
      customerName: json['customerName']?.toString() ?? json['customer_name']?.toString(),
      cashierId: int.tryParse((json['cashierId'] ?? json['cashier_id'] ?? '1').toString()) ?? 1,
      cashierName: json['cashierName']?.toString() ?? json['cashier_name']?.toString(),
      subtotal: double.tryParse((json['subtotal'] ?? '0').toString()) ?? 0.0,
      discountAmount: double.tryParse((json['discountAmount'] ?? json['discount_amount'] ?? '0').toString()) ?? 0.0,
      taxAmount: double.tryParse((json['taxAmount'] ?? json['tax_amount'] ?? '0').toString()) ?? 0.0,
      grandTotal: double.tryParse((json['grandTotal'] ?? json['grand_total'] ?? '0').toString()) ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? json['payment_status']?.toString() ?? 'paid',
      orderStatus: json['orderStatus']?.toString() ?? json['order_status']?.toString() ?? 'paid',
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      amountReceived: double.tryParse((json['amountReceived'] ?? json['amount_received'] ?? '0').toString()) ?? 0.0,
      changeAmount: double.tryParse((json['changeAmount'] ?? json['change_amount'] ?? '0').toString()) ?? 0.0,
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
