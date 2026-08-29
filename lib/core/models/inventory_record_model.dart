class InventoryRecordModel {
  final int id;
  final String sku;
  final String itemName;
  final String category;
  final int quantityInStock;
  final double unitCost;
  final int reorderLevel;
  final DateTime? updatedAt;

  const InventoryRecordModel({
    required this.id,
    required this.sku,
    required this.itemName,
    required this.category,
    required this.quantityInStock,
    required this.unitCost,
    required this.reorderLevel,
    this.updatedAt,
  });

  double get totalValue => quantityInStock * unitCost;

  /// 'out' | 'low' | 'ok'
  String get stockStatus {
    if (quantityInStock == 0) return 'out';
    if (quantityInStock <= reorderLevel) return 'low';
    return 'ok';
  }

  factory InventoryRecordModel.fromJson(Map<String, dynamic> json) => InventoryRecordModel.fromMap(json);
  factory InventoryRecordModel.fromMap(Map<String, dynamic> json) {
    return InventoryRecordModel(
      id: json['id'] as int,
      sku: json['sku']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      quantityInStock: (json['quantity_in_stock'] as num?)?.toInt() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ??
          double.tryParse(json['unit_cost'].toString()) ??
          0,
      reorderLevel: (json['reorder_level'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}