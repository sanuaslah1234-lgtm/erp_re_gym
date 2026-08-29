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
      createdAt: map['created_at'] as DateTime?,
      updatedAt: map['updated_at'] as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'productName': productName,
      'sku': sku,
      'warehouseName': warehouseName,
      'quantity': quantity,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'reorderLevel': reorderLevel,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // UI Helpers
  String get product => productName ?? 'Unknown Product';
  String get warehouse => warehouseName ?? 'Main Warehouse';
  int get minStock => minimumStock;
  int get maxStock => maximumStock;
}