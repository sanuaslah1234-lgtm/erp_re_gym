class InventorySummaryModel {
  final double totalStockValue;
  final int totalItems;
  final int lowStock;
  final int outOfStock;

  const InventorySummaryModel({
    required this.totalStockValue,
    required this.totalItems,
    required this.lowStock,
    required this.outOfStock,
  });

  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) => InventorySummaryModel.fromMap(json);
  factory InventorySummaryModel.fromMap(Map<String, dynamic> json) {
    return InventorySummaryModel(
      totalStockValue: (json['total_stock_value'] as num?)?.toDouble() ?? 0,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      lowStock: (json['low_stock'] as num?)?.toInt() ?? 0,
      outOfStock: (json['out_of_stock'] as num?)?.toInt() ?? 0,
    );
  }

  factory InventorySummaryModel.empty() =>
      const InventorySummaryModel(totalStockValue: 0, totalItems: 0, lowStock: 0, outOfStock: 0);
}