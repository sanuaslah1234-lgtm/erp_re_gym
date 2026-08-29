class SalesRecordModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final double subtotal;
  final double discount;
  final double total;
  final String status;
  final DateTime? createdAt;

  const SalesRecordModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory SalesRecordModel.fromJson(Map<String, dynamic> json) => SalesRecordModel.fromMap(json);
  factory SalesRecordModel.fromMap(Map<String, dynamic> json) {
    return SalesRecordModel(
      id: json['id'] as int,
      orderNumber: json['order_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ??
          double.tryParse(json['subtotal'].toString()) ??
          0,
      discount: (json['discount'] as num?)?.toDouble() ??
          double.tryParse(json['discount'].toString()) ??
          0,
      total: (json['total'] as num?)?.toDouble() ??
          double.tryParse(json['total'].toString()) ??
          0,
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_name': customerName,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}