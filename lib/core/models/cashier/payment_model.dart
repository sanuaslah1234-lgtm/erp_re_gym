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
      id: int.tryParse(json['id'].toString()),
      orderId: int.tryParse((json['orderId'] ?? json['order_id'] ?? '').toString()),
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'] ?? 'Cash').toString(),
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0.0,
      referenceNumber: json['referenceNumber']?.toString() ?? json['reference_number']?.toString(),
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
