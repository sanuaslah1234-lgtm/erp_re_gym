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
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      orderId: json['orderId'] is int ? json['orderId'] as int : (json['order_id'] is int ? json['order_id'] as int : int.tryParse((json['orderId'] ?? json['order_id'] ?? '').toString())),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'Cash',
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0.0,
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
