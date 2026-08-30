class InventoryModel {
  final String id;
  final String productId;
  final String warehouseId;
  final String? productName;
  final String? sku;
  final String? warehouseName;
  final int quantity;
  final int minimumStock;
  final int maximumStock;
  final int reorderLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InventoryModel({
    required this.id,
    required this.productId,
    required this.warehouseId,
    this.productName,
    this.sku,
    this.warehouseName,
    required this.quantity,
    required this.minimumStock,
    required this.maximumStock,
    required this.reorderLevel,
    this.createdAt,
    this.updatedAt,
  });

  String get status {
    if (quantity <= 0) {
      return 'Out of Stock';
    }
    if (quantity <= minimumStock) {
      return 'Low Stock';
    }
    return 'In Stock';
  }

  factory InventoryModel.fromJson(Map<String, dynamic> json) => InventoryModel.fromMap(json);
  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic val, int fallback) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? fallback;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return InventoryModel(
      id: map['id']?.toString() ?? '',
      productId: map['product_id']?.toString() ?? map['productId']?.toString() ?? '',
      warehouseId: map['warehouse_id']?.toString() ?? map['warehouseId']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? map['productName']?.toString() ?? map['product']?.toString() ?? map['name']?.toString(),
      sku: map['sku']?.toString() ?? map['product_code']?.toString() ?? map['barcode']?.toString(),
      warehouseName: map['warehouse_name']?.toString() ?? map['warehouseName']?.toString() ?? map['warehouse']?.toString(),
      quantity: parseInt(map['quantity'], 0),
      minimumStock: parseInt(map['minimum_stock'] ?? map['minimumStock'] ?? map['minStock'], 10),
      maximumStock: parseInt(map['maximum_stock'] ?? map['maximumStock'] ?? map['maxStock'], 1000),
      reorderLevel: parseInt(map['reorder_level'] ?? map['reorderLevel'], 20),
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'product_id': productId,
      'warehouseId': warehouseId,
      'warehouse_id': warehouseId,
      'productName': productName,
      'product_name': productName,
      'product': productName,
      'sku': sku,
      'product_code': sku,
      'warehouseName': warehouseName,
      'warehouse_name': warehouseName,
      'warehouse': warehouseName,
      'quantity': quantity,
      'minimumStock': minimumStock,
      'minimum_stock': minimumStock,
      'maximumStock': maximumStock,
      'maximum_stock': maximumStock,
      'reorderLevel': reorderLevel,
      'reorder_level': reorderLevel,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // UI Helpers
  String get product => productName ?? 'Unknown Product';
  String get warehouse => warehouseName ?? 'Main Warehouse';
  int get minStock => minimumStock;
  int get maxStock => maximumStock;
}