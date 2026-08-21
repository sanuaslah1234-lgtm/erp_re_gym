class PurchaseItemModel {
  final int? id;
  final int? purchaseId;
  final int productId;
  final String? productName;
  final String? productCode;
  final double quantity;
  final double purchasePrice;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;

  PurchaseItemModel({
    this.id,
    this.purchaseId,
    required this.productId,
    this.productName,
    this.productCode,
    required this.quantity,
    required this.purchasePrice,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
  });

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? defaultVal;
  }

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'] as int?,
      purchaseId: json['purchaseId'] ?? json['purchase_id'],
      productId: json['productId'] ?? json['product_id'],
      productName: json['productName'] ?? json['product_name'],
      productCode: json['productCode'] ?? json['product_code'],
      quantity: _parseDouble(json['quantity']),
      purchasePrice: _parseDouble(json['purchasePrice'] ?? json['purchase_price']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax_amount']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseId': purchaseId,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
    };
  }
}

class PurchaseModel {
  final int? id;
  final String invoiceNumber;
  final int? supplierId;
  final String? supplierName;
  final DateTime purchaseDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentStatus;
  final int? createdBy;
  final DateTime? createdAt;
  final List<PurchaseItemModel> items;

  PurchaseModel({
    this.id,
    required this.invoiceNumber,
    this.supplierId,
    this.supplierName,
    DateTime? purchaseDate,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.paymentStatus = 'paid',
    this.createdBy,
    this.createdAt,
    this.items = const [],
  }) : purchaseDate = purchaseDate ?? DateTime.now();

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? defaultVal;
  }

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as int?,
      invoiceNumber: (json['invoiceNumber'] ?? json['invoice_number'] ?? '').toString(),
      supplierId: json['supplierId'] ?? json['supplier_id'],
      supplierName: json['supplierName'] ?? json['supplier_name'],
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate'].toString()) : (json['purchase_date'] != null ? DateTime.parse(json['purchase_date'].toString()) : DateTime.now()),
      subtotal: _parseDouble(json['subtotal']),
      taxAmount: _parseDouble(json['taxAmount'] ?? json['tax_amount']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
      paymentStatus: (json['paymentStatus'] ?? json['payment_status'] ?? 'paid').toString(),
      createdBy: json['createdBy'] ?? json['created_by'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      items: (json['items'] as List<dynamic>?)?.map((i) => PurchaseItemModel.fromJson(i as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'purchaseDate': purchaseDate.toIso8601String(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
