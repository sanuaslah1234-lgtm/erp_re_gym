class PurchaseRecordModel {
  final int id;
  final String poNumber;
  final String supplierName;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime? createdAt;

  const PurchaseRecordModel({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory PurchaseRecordModel.fromJson(Map<String, dynamic> json) => PurchaseRecordModel.fromMap(json);
  factory PurchaseRecordModel.fromMap(Map<String, dynamic> json) {
    return PurchaseRecordModel(
      id: json['id'] as int,
      poNumber: json['po_number']?.toString() ?? '',
      supplierName: json['supplier_name']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ??
          double.tryParse(json['subtotal'].toString()) ??
          0,
      tax: (json['tax'] as num?)?.toDouble() ?? double.tryParse(json['tax'].toString()) ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? double.tryParse(json['total'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}