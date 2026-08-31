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

  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['orderId'] ?? json['order_id'] ?? json['invoice_id']),
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'] ?? json['method'] ?? 'Cash').toString(),
      amount: _parseDouble(json['amount']),
      referenceNumber: (json['referenceNumber'] ?? json['reference_number'])?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : (json['payment_date'] != null ? DateTime.tryParse(json['payment_date'].toString()) : null)),
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
