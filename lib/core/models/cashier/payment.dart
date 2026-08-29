class Payment {
  final int? id;
  final int? orderId;
  final String paymentMethod;
  final double amount;
  final String? referenceNumber;
  final DateTime? createdAt;

  Payment({
    this.id,
    this.orderId,
    required this.paymentMethod,
    required this.amount,
    this.referenceNumber,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
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
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
      'reference_number': referenceNumber,
    };
  }
}
