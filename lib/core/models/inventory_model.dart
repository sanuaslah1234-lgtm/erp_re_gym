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
    return InventoryModel(
      id: map['id'].toString(),
      productId: map['product_id'].toString(),
      warehouseId: map['warehouse_id'].toString(),
      productName: map['product_name']?.toString(),
      sku: map['sku']?.toString(),
      warehouseName: map['warehouse_name']?.toString(),
      quantity: map['quantity'] as int? ?? 0,
      minimumStock: map['minimum_stock'] as int? ?? 10,
      maximumStock: map['maximum_stock'] as int? ?? 1000,
      reorderLevel: map['reorder_level'] as int? ?? 20,
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'product_name': productName,
      'sku': sku,
      'warehouse_name': warehouseName,
      'quantity': quantity,
      'minimum_stock': minimumStock,
      'maximum_stock': maximumStock,
      'reorder_level': reorderLevel,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // UI Helpers
  String get product => productName ?? 'Unknown Product';
  String get warehouse => warehouseName ?? 'Main Warehouse';
  int get minStock => minimumStock;
  int get maxStock => maximumStock;

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}