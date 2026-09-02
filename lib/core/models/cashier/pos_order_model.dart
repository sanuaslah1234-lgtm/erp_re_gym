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

  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory PosOrderModel.fromJson(Map<String, dynamic> json) {
    return PosOrderModel(
      id: _parseInt(json['id']),
      orderNumber: json['orderNumber']?.toString() ?? json['order_number']?.toString() ?? '',
      customerId: _parseInt(json['customerId'] ?? json['customer_id']),
      customerName: json['customerName']?.toString() ?? json['customer_name']?.toString(),
      cashierId: _parseInt(json['cashierId'] ?? json['cashier_id']) ?? 1,
      cashierName: json['cashierName']?.toString() ?? json['cashier_name']?.toString(),
      subtotal: _parseDouble(json['subtotal'] ?? json['subtotal_amount']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax_amount']),
      grandTotal: _parseDouble(json['grandTotal'] ?? json['grand_total']),
      paymentStatus: json['paymentStatus']?.toString() ?? json['payment_status']?.toString() ?? 'paid',
      orderStatus: json['orderStatus']?.toString() ?? json['order_status']?.toString() ?? 'paid',
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      amountReceived: _parseDouble(json['amountReceived'] ?? json['amount_received']),
      changeAmount: _parseDouble(json['changeAmount'] ?? json['change_amount']),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItemModel.fromJson(i is Map<String, dynamic> ? i : Map<String, dynamic>.from(i as Map))).toList()
          : [],
      payments: json['payments'] != null
          ? (json['payments'] as List).map((p) => PaymentModel.fromJson(p is Map<String, dynamic> ? p : Map<String, dynamic>.from(p as Map))).toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null),
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
