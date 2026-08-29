class PurchaseSummaryModel {
  final double totalSpend;
  final int purchaseOrders;
  final double averageValue;
  final double totalTax;

  const PurchaseSummaryModel({
    required this.totalSpend,
    required this.purchaseOrders,
    required this.averageValue,
    required this.totalTax,
  });

  factory PurchaseSummaryModel.fromJson(Map<String, dynamic> json) => PurchaseSummaryModel.fromMap(json);
  factory PurchaseSummaryModel.fromMap(Map<String, dynamic> json) {
    return PurchaseSummaryModel(
      totalSpend: (json['total_spend'] as num?)?.toDouble() ?? 0,
      purchaseOrders: (json['purchase_orders'] as num?)?.toInt() ?? 0,
      averageValue: (json['average_value'] as num?)?.toDouble() ?? 0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0,
    );
  }

  factory PurchaseSummaryModel.empty() =>
      const PurchaseSummaryModel(totalSpend: 0, purchaseOrders: 0, averageValue: 0, totalTax: 0);
}