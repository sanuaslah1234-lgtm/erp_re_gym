class StockMovementModel {
  final dynamic id;
  final dynamic productId;
  final String? productName;
  final String? productCode;
  final String movementType;
  final double quantity;
  final double previousStock;
  final double newStock;
  final String? referenceId;
  final String? notes;
  final dynamic createdBy;
  final DateTime? createdAt;

  StockMovementModel({
    this.id,
    required this.productId,
    this.productName,
    this.productCode,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.referenceId,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? defaultVal;
  }

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'],
      productId: json['productId'] ?? json['product_id'],
      productName: json['productName'] ?? json['product_name'],
      productCode: json['productCode'] ?? json['product_code'],
      movementType: (json['movementType'] ?? json['movement_type'] ?? '').toString(),
      quantity: _parseDouble(json['quantity']),
      previousStock: _parseDouble(json['previousStock'] ?? json['previous_stock']),
      newStock: _parseDouble(json['newStock'] ?? json['new_stock']),
      referenceId: json['referenceId'] ?? json['reference_id'],
      notes: json['notes']?.toString(),
      createdBy: json['createdBy'] ?? json['created_by'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'movementType': movementType,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'referenceId': referenceId,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
