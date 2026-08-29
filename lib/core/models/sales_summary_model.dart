class SalesSummaryModel {
  final double totalRevenue;
  final int salesOrders;
  final double averageValue;
  final double totalDiscounts;

  const SalesSummaryModel({
    required this.totalRevenue,
    required this.salesOrders,
    required this.averageValue,
    required this.totalDiscounts,
  });

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) => SalesSummaryModel.fromMap(json);
  factory SalesSummaryModel.fromMap(Map<String, dynamic> json) {
    return SalesSummaryModel(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      salesOrders: (json['sales_orders'] as num?)?.toInt() ?? 0,
      averageValue: (json['average_value'] as num?)?.toDouble() ?? 0,
      totalDiscounts: (json['total_discounts'] as num?)?.toDouble() ?? 0,
    );
  }

  factory SalesSummaryModel.empty() => const SalesSummaryModel(
        totalRevenue: 0,
        salesOrders: 0,
        averageValue: 0,
        totalDiscounts: 0,
      );
}