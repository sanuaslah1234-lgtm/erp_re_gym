class PaymentModel {
  final int? id;
  final int? orderId;
  final String paymentMethod; // 'Cash', 'Card', 'UPI', 'Mixed'
  final double amount;
  final String? referenceNumber;
  final DateTime? createdAt;

  PaymentModel({
    this.id,
    this.orderId,
    required this.paymentMethod,
    required this.amount,
    this.referenceNumber,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int?,
      orderId: json['orderId'] ?? json['order_id'],
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'Cash',
      amount: (json['amount'] ?? 0.0).toDouble(),
      referenceNumber: json['referenceNumber'] ?? json['reference_number'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
